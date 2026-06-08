// Handles ZiniPay redirect/cancel callbacks.
// Flutter WebView intercepts navigation to this URL to detect payment outcome.
Deno.serve(async (req: Request) => {
  const url = new URL(req.url)
  const status = url.searchParams.get('status') ?? 'cancel'

  const isSuccess = status === 'success'
  const title = isSuccess ? 'Payment Successful' : 'Payment Cancelled'
  const color = isSuccess ? '#7c3aed' : '#ef4444'
  const icon = isSuccess ? '✓' : '✕'

  const html = `<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${title}</title>
  <style>
    body { background: #0f0f1a; display: flex; align-items: center;
           justify-content: center; height: 100vh; margin: 0;
           font-family: -apple-system, sans-serif; }
    .box { text-align: center; }
    .icon { font-size: 64px; color: ${color}; }
    h1 { color: ${color}; font-size: 24px; margin: 16px 0 8px; }
    p { color: #888; font-size: 14px; }
  </style>
</head>
<body>
  <div class="box">
    <div class="icon">${icon}</div>
    <h1>${title}</h1>
    <p>Returning to BOLOO...</p>
  </div>
</body>
</html>`

  return new Response(html, {
    headers: { 'Content-Type': 'text/html' },
  })
})
