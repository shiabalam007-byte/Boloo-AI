import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { hmac } from 'https://deno.land/x/hmac@v2.0.1/mod.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const zinnipaySecret = Deno.env.get('ZINNIPAY_WEBHOOK_SECRET')!

    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    const signature = req.headers.get('x-zinnipay-signature')
    const body = await req.text()

    const expectedSig = await hmac('sha256', zinnipaySecret, body, 'utf8', 'hex')
    if (signature !== expectedSig) {
      return new Response('Invalid signature', { status: 401 })
    }

    const payload = JSON.parse(body)
    const { transaction_id, order_id, status, amount, payment_method } = payload

    await supabase.from('payments').update({
      transaction_id,
      status: status === 'SUCCESS' ? 'success' : 'failed',
      payment_method,
      gateway_response: payload,
    }).eq('id', order_id)

    if (status === 'SUCCESS') {
      const { data: payment } = await supabase
        .from('payments')
        .select('user_id')
        .eq('id', order_id)
        .single()

      if (payment?.user_id) {
        const now = new Date()
        const expiresAt = new Date(now)
        expiresAt.setDate(expiresAt.getDate() + 180)

        await supabase.from('subscriptions').insert({
          user_id: payment.user_id,
          plan_type: 'accelerator_30',
          status: 'active',
          amount_bdt: amount / 100,
          payment_id: order_id,
          started_at: now.toISOString(),
          expires_at: expiresAt.toISOString(),
        })

        await supabase.from('user_profiles').update({
          journey_start_date: now.toISOString().split('T')[0],
          current_day: 1,
        }).eq('id', payment.user_id)

        await supabase.from('user_journey_progress').insert({
          user_id: payment.user_id,
          day_number: 1,
          status: 'unlocked',
        })
      }
    }

    return new Response('OK', { status: 200 })
  } catch (error) {
    console.error('Webhook error:', error)
    return new Response('Error', { status: 500 })
  }
})
