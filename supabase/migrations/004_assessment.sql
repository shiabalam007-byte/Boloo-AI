-- =============================================
-- BOLOO AI — Assessment Funnel
-- =============================================

ALTER TABLE public.user_profiles
  ADD COLUMN IF NOT EXISTS assessment_completed BOOLEAN DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS assessment_result    JSONB;

-- Extend session_type to include assessment conversations
ALTER TABLE public.conversations
  DROP CONSTRAINT IF EXISTS conversations_session_type_check;

ALTER TABLE public.conversations
  ADD CONSTRAINT conversations_session_type_check
    CHECK (session_type IN ('daily_challenge','free_practice','assessment'));
