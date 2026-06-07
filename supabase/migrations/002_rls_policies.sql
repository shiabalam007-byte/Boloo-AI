-- =============================================
-- BOLOO AI — Row Level Security Policies
-- =============================================

-- USER PROFILES
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users_read_own_profile" ON public.user_profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "users_update_own_profile" ON public.user_profiles
  FOR UPDATE USING (auth.uid() = id);

-- SUBSCRIPTIONS
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users_read_own_subscription" ON public.subscriptions
  FOR SELECT USING (auth.uid() = user_id);

-- PAYMENTS
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users_read_own_payments" ON public.payments
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "users_create_own_payments" ON public.payments
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- CONVERSATIONS
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users_crud_own_conversations" ON public.conversations
  USING (auth.uid() = user_id);

-- MESSAGES
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users_crud_own_messages" ON public.messages
  USING (
    conversation_id IN (
      SELECT id FROM public.conversations WHERE user_id = auth.uid()
    )
  );

-- STREAKS
ALTER TABLE public.streaks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users_crud_own_streaks" ON public.streaks
  USING (auth.uid() = user_id);

-- SCORE HISTORY
ALTER TABLE public.score_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users_read_own_scores" ON public.score_history
  FOR SELECT USING (auth.uid() = user_id);

-- USER JOURNEY PROGRESS
ALTER TABLE public.user_journey_progress ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users_crud_own_journey" ON public.user_journey_progress
  USING (auth.uid() = user_id);

-- CURRICULUM DAYS (public read for authenticated users)
ALTER TABLE public.curriculum_days ENABLE ROW LEVEL SECURITY;

CREATE POLICY "authenticated_read_curriculum" ON public.curriculum_days
  FOR SELECT TO authenticated USING (true);
