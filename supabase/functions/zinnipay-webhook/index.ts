import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

async function verifyHmacSha256(secret: string, message: string, signature: string): Promise<boolean> {
  if (!signature || signature.length % 2 !== 0) return false
  const enc = new TextEncoder()
  const key = await crypto.subtle.importKey(
    'raw',
    enc.encode(secret),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['verify'],
  )
  const sigBytes = new Uint8Array(signature.length / 2)
  for (let i = 0; i < signature.length; i += 2) {
    sigBytes[i / 2] = parseInt(signature.substring(i, i + 2), 16)
  }
  return crypto.subtle.verify('HMAC', key, sigBytes, enc.encode(message))
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const zinnipaySecret = Deno.env.get('ZINNIPAY_WEBHOOK_SECRET')!

    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    const signature = req.headers.get('x-zinnipay-signature') ?? ''
    const body = await req.text()

    const valid = await verifyHmacSha256(zinnipaySecret, body, signature)
    if (!valid) {
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
        expiresAt.setDate(expiresAt.getDate() + 90)

        await supabase.from('subscriptions').insert({
          user_id: payment.user_id,
          plan_type: 'accelerator_90',
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
