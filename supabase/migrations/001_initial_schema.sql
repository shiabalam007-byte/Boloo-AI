-- =============================================
-- BOLOO AI — Initial Database Schema
-- =============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================================
-- USER PROFILES (extends auth.users)
-- =============================================
CREATE TABLE public.user_profiles (
  id                    UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name             TEXT,
  avatar_url            TEXT,
  phone                 TEXT,
  language_preference   TEXT DEFAULT 'mixed'
                        CHECK (language_preference IN ('bangla','english','mixed')),
  primary_goal          TEXT
                        CHECK (primary_goal IN ('jobInterview','freelancing','corporate','ielts','abroad')),
  english_level         TEXT
                        CHECK (english_level IN ('beginner','intermediate','upperIntermediate')),
  occupation            TEXT,
  daily_commitment_min  INT DEFAULT 15,
  journey_start_date    DATE,
  current_day           INT DEFAULT 1,
  onboarding_completed  BOOLEAN DEFAULT FALSE,
  total_sessions        INT DEFAULT 0,
  total_minutes         INT DEFAULT 0,
  created_at            TIMESTAMPTZ DEFAULT NOW(),
  updated_at            TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- PAYMENTS
-- =============================================
CREATE TABLE public.payments (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id           UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  amount_bdt        INT NOT NULL,
  currency          TEXT DEFAULT 'BDT',
  gateway           TEXT DEFAULT 'zinnipay',
  payment_method    TEXT,
  transaction_id    TEXT UNIQUE,
  gateway_response  JSONB,
  status            TEXT DEFAULT 'pending'
                    CHECK (status IN ('pending','success','failed','refunded')),
  created_at        TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- SUBSCRIPTIONS
-- =============================================
CREATE TABLE public.subscriptions (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id       UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  plan_type     TEXT DEFAULT 'accelerator_30'
                CHECK (plan_type IN ('accelerator_30')),
  status        TEXT DEFAULT 'pending'
                CHECK (status IN ('pending','active','expired','cancelled')),
  amount_bdt    INT DEFAULT 1999,
  payment_id    UUID REFERENCES public.payments(id),
  started_at    TIMESTAMPTZ,
  expires_at    TIMESTAMPTZ,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- CONVERSATIONS (SESSIONS)
-- =============================================
CREATE TABLE public.conversations (
  id                    UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id               UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  session_type          TEXT DEFAULT 'daily_challenge'
                        CHECK (session_type IN ('daily_challenge','free_practice')),
  mode                  TEXT DEFAULT 'text'
                        CHECK (mode IN ('voice','text')),
  journey_day           INT,
  topic                 TEXT,
  scenario              TEXT,
  started_at            TIMESTAMPTZ DEFAULT NOW(),
  ended_at              TIMESTAMPTZ,
  duration_sec          INT,
  message_count         INT DEFAULT 0,
  confidence_score      NUMERIC(5,2),
  fluency_score         NUMERIC(5,2),
  communication_score   NUMERIC(5,2),
  overall_score         NUMERIC(5,2),
  maya_feedback         TEXT,
  created_at            TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- MESSAGES
-- =============================================
CREATE TABLE public.messages (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  conversation_id   UUID NOT NULL REFERENCES public.conversations(id) ON DELETE CASCADE,
  role              TEXT NOT NULL CHECK (role IN ('user','maya')),
  content           TEXT NOT NULL,
  audio_url         TEXT,
  duration_ms       INT,
  word_count        INT,
  created_at        TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- STREAKS
-- =============================================
CREATE TABLE public.streaks (
  user_id             UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  current_streak      INT DEFAULT 0,
  longest_streak      INT DEFAULT 0,
  last_practice_date  DATE,
  total_active_days   INT DEFAULT 0,
  updated_at          TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- SCORE HISTORY (for charts)
-- =============================================
CREATE TABLE public.score_history (
  id                    UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id               UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  conversation_id       UUID NOT NULL REFERENCES public.conversations(id) ON DELETE CASCADE,
  confidence_score      NUMERIC(5,2),
  fluency_score         NUMERIC(5,2),
  communication_score   NUMERIC(5,2),
  overall_score         NUMERIC(5,2),
  recorded_at           TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- CURRICULUM DAYS (admin-seeded)
-- =============================================
CREATE TABLE public.curriculum_days (
  day_number            INT PRIMARY KEY,
  week_number           INT NOT NULL,
  phase                 TEXT NOT NULL,
  title_en              TEXT NOT NULL,
  title_bn              TEXT NOT NULL,
  description_en        TEXT,
  description_bn        TEXT,
  scenario_type         TEXT NOT NULL,
  scenario_prompt       TEXT NOT NULL,
  learning_objectives   TEXT[] DEFAULT '{}',
  key_phrases           TEXT[] DEFAULT '{}',
  difficulty            INT DEFAULT 1 CHECK (difficulty BETWEEN 1 AND 5),
  estimated_min         INT DEFAULT 15,
  is_milestone          BOOLEAN DEFAULT FALSE
);

-- =============================================
-- USER JOURNEY PROGRESS
-- =============================================
CREATE TABLE public.user_journey_progress (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id           UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  day_number        INT NOT NULL REFERENCES public.curriculum_days(day_number),
  status            TEXT DEFAULT 'locked'
                    CHECK (status IN ('locked','unlocked','completed')),
  conversation_id   UUID REFERENCES public.conversations(id),
  completed_at      TIMESTAMPTZ,
  UNIQUE(user_id, day_number)
);

-- =============================================
-- INDEXES
-- =============================================
CREATE INDEX idx_conversations_user_id ON public.conversations(user_id);
CREATE INDEX idx_conversations_created_at ON public.conversations(created_at DESC);
CREATE INDEX idx_messages_conversation_id ON public.messages(conversation_id);
CREATE INDEX idx_score_history_user_id ON public.score_history(user_id);
CREATE INDEX idx_score_history_recorded_at ON public.score_history(recorded_at DESC);
CREATE INDEX idx_user_journey_user_id ON public.user_journey_progress(user_id);
CREATE INDEX idx_subscriptions_user_id ON public.subscriptions(user_id);
CREATE INDEX idx_payments_user_id ON public.payments(user_id);

-- =============================================
-- UPDATED_AT TRIGGER
-- =============================================
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON public.user_profiles
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- =============================================
-- AUTO-CREATE USER PROFILE ON SIGNUP
-- =============================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.user_profiles (id, full_name, avatar_url)
  VALUES (
    NEW.id,
    NEW.raw_user_meta_data->>'full_name',
    NEW.raw_user_meta_data->>'avatar_url'
  );

  INSERT INTO public.streaks (user_id)
  VALUES (NEW.id);

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
