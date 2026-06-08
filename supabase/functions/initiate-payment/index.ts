import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface InitiatePaymentRequest {
  paymentId: string
  userId: string
  amountBdt: number
  customerName: string
  customerEmail: string
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const zinipayApiKey = Deno.env.get('ZINIPAY_API_KEY')
    if (!zinipayApiKey) throw new Error('ZINIPAY_API_KEY not configured')

    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const webhookUrl = `${supabaseUrl}/functions/v1/zinnipay-webhook`

    const supabase = createClient(supabaseUrl, supabaseServiceKey)
    const body: InitiatePaymentRequest = await req.json()

    // ZiniPay API: https://api.zinipay.com — single 'n', auth via zini-api-key header
    // amount is in BDT directly (not paisa)
    // redirect_url and cancel_url must share a domain matching the brand's
    // registered website in the ZiniPay dashboard. Using the Supabase project
    // URL here since it's already trusted for webhook_url.
    // Flutter WebView intercepts navigation to /payment-return?status=...
    const returnBase = `${supabaseUrl}/functions/v1/payment-return`

    const payload = {
      amount: body.amountBdt,
      cus_name: body.customerName,
      cus_email: body.customerEmail,
      redirect_url: `${returnBase}?status=success`,
      cancel_url: `${returnBase}?status=cancel`,
      webhook_url: webhookUrl,
      metadata: { payment_id: body.paymentId },
    }

    const response = await fetch('https://api.zinipay.com/v1/payment/create', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'zini-api-key': zinipayApiKey,
      },
      body: JSON.stringify(payload),
    })

    const responseText = await response.text()

    if (!response.ok) {
      throw new Error(`ZiniPay error ${response.status}: ${responseText}`)
    }

    const data = JSON.parse(responseText)

    if (!data.payment_url) {
      throw new Error(`ZiniPay returned no payment_url: ${responseText}`)
    }

    // Extract invoice_id from payment_url: https://secure.zinipay.com/payment/INVOICE_ID
    const invoiceId = data.payment_url.split('/').pop() ?? null

    // Store invoice_id so the webhook handler can reconcile the payment
    if (invoiceId) {
      await supabase
        .from('payments')
        .update({ zinipay_invoice_id: invoiceId })
        .eq('id', body.paymentId)
    }

    return new Response(
      JSON.stringify({ payment_url: data.payment_url, invoice_id: invoiceId }),
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
