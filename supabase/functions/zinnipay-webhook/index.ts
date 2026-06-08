import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// ZiniPay webhook — no HMAC signatures; security is enforced by calling
// the ZiniPay verify API from the backend before any action is taken.

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', {
      headers: { 'Access-Control-Allow-Headers': 'content-type' },
    })
  }

  try {
    const zinipayApiKey = Deno.env.get('ZINIPAY_API_KEY')
    if (!zinipayApiKey) throw new Error('ZINIPAY_API_KEY not configured')

    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // ZiniPay webhook payload: { invoice_id: string, status: "true" | "false" }
    const body = await req.json()
    const { invoice_id } = body

    if (!invoice_id) {
      console.error('Webhook received without invoice_id:', JSON.stringify(body))
      return new Response('Missing invoice_id', { status: 400 })
    }

    // Step 1: Verify payment with ZiniPay backend — the only authoritative source of truth
    const verifyResponse = await fetch('https://api.zinipay.com/v1/payment/verify', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'zini-api-key': zinipayApiKey,
      },
      body: JSON.stringify({ invoice_id }),
    })

    if (!verifyResponse.ok) {
      const errText = await verifyResponse.text()
      console.error('ZiniPay verify failed:', errText)
      return new Response('Verification failed', { status: 400 })
    }

    // verified: { cus_name, cus_email, amount, invoice_id, payment_method, transaction_id, status }
    // status values: COMPLETED | PENDING | FAILED
    const verified = await verifyResponse.json()

    console.log('ZiniPay verified:', JSON.stringify({
      invoice_id,
      status: verified.status,
      amount: verified.amount,
      transaction_id: verified.transaction_id,
    }))

    // Step 2: Look up our payment record by the stored invoice_id
    const { data: payment } = await supabase
      .from('payments')
      .select('id, user_id')
      .eq('zinipay_invoice_id', invoice_id)
      .maybeSingle()

    if (!payment) {
      // Unknown invoice — log and acknowledge to prevent ZiniPay retries
      console.error('No payment record found for invoice_id:', invoice_id)
      return new Response('OK', { status: 200 })
    }

    // Step 3: Update payment record with verified transaction data
    await supabase.from('payments').update({
      transaction_id: verified.transaction_id ?? null,
      status: verified.status === 'COMPLETED' ? 'success' : 'failed',
      payment_method: verified.payment_method ?? null,
      gateway_response: verified,
    }).eq('id', payment.id)

    // Step 4: Activate subscription only after confirmed COMPLETED status
    if (verified.status === 'COMPLETED') {
      // Check for existing active subscription to prevent duplicates
      const { data: existing } = await supabase
        .from('subscriptions')
        .select('id')
        .eq('payment_id', payment.id)
        .maybeSingle()

      if (!existing) {
        const now = new Date()
        const expiresAt = new Date(now)
        expiresAt.setDate(expiresAt.getDate() + 90)

        await supabase.from('subscriptions').insert({
          user_id: payment.user_id,
          plan_type: 'accelerator_90',
          status: 'active',
          amount_bdt: verified.amount,
          payment_id: payment.id,
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
        }).onConflict('user_id, day_number').ignore()

        console.log('Subscription activated for user:', payment.user_id)
      }
    }

    return new Response('OK', { status: 200 })
  } catch (error) {
    console.error('Webhook error:', error)
    return new Response('Error', { status: 500 })
  }
})
