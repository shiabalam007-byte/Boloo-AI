import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface InitiatePaymentRequest {
  paymentId: string
  userId: string
  amountPaisa: number
  customerName: string
  customerEmail: string
  customerPhone: string
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const zinnipayApiKey = Deno.env.get('ZINNIPAY_API_KEY')
    const zinnipayBaseUrl = Deno.env.get('ZINNIPAY_BASE_URL') ?? 'https://api.zinnipay.com/v1'
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const webhookUrl = `${supabaseUrl}/functions/v1/zinnipay-webhook`

    const supabase = createClient(supabaseUrl, supabaseServiceKey)
    const body: InitiatePaymentRequest = await req.json()

    const payload = {
      amount: body.amountPaisa,
      currency: 'BDT',
      order_id: body.paymentId,
      customer: {
        name: body.customerName,
        email: body.customerEmail,
        phone: body.customerPhone,
      },
      return_url: 'boloo://payment/return',
      cancel_url: 'boloo://payment/cancel',
      webhook_url: webhookUrl,
      description: 'BOLOO AI 90-Day Career Accelerator',
    }

    const response = await fetch(`${zinnipayBaseUrl}/payment/create`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${zinnipayApiKey}`,
      },
      body: JSON.stringify(payload),
    })

    if (!response.ok) {
      const error = await response.text()
      throw new Error(`Zinnipay error: ${error}`)
    }

    const data = await response.json()

    return new Response(
      JSON.stringify({
        payment_url: data.payment_url,
        session_id: data.session_id,
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: (error as Error).message }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    )
  }
})
