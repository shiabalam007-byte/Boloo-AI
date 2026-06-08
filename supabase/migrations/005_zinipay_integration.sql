-- =============================================
-- ZiniPay Integration Fix
-- - Add zinipay_invoice_id to payments for webhook reconciliation
-- - Update subscriptions plan_type to support accelerator_90
-- =============================================

ALTER TABLE public.payments
  ADD COLUMN IF NOT EXISTS zinipay_invoice_id TEXT UNIQUE;

CREATE INDEX IF NOT EXISTS idx_payments_zinipay_invoice_id
  ON public.payments(zinipay_invoice_id);

ALTER TABLE public.subscriptions
  DROP CONSTRAINT IF EXISTS subscriptions_plan_type_check;

ALTER TABLE public.subscriptions
  ADD CONSTRAINT subscriptions_plan_type_check
  CHECK (plan_type IN ('accelerator_30', 'accelerator_90'));

ALTER TABLE public.subscriptions
  ALTER COLUMN plan_type SET DEFAULT 'accelerator_90';
