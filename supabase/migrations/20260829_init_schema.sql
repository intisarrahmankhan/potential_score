-- ====================================================================
-- Supabase PostgreSQL Schema Migration: Daily Potential & Habit Tracker
-- ====================================================================

-- 1. Create Habit Type Enum
CREATE TYPE habit_type_enum AS ENUM (
    'boolean',
    'numeric_range',
    'numeric_min',
    'numeric_max'
);

-- 2. Profiles Table (Extends auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT,
    full_name TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS on Profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own profile"
    ON public.profiles FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
    ON public.profiles FOR UPDATE
    USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile"
    ON public.profiles FOR INSERT
    WITH CHECK (auth.uid() = id);

-- 3. Habits Table (Dynamic Rule Configuration)
CREATE TABLE IF NOT EXISTS public.habits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    category TEXT DEFAULT 'custom',
    habit_type habit_type_enum NOT NULL DEFAULT 'boolean',
    unit TEXT DEFAULT '',
    target_min DOUBLE PRECISION,
    target_max DOUBLE PRECISION,
    is_active BOOLEAN DEFAULT true NOT NULL,
    order_index INTEGER DEFAULT 0 NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS on Habits
ALTER TABLE public.habits ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own habits"
    ON public.habits FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE INDEX idx_habits_user_order ON public.habits(user_id, order_index);

-- 4. Daily Logs Table (Retrospective Daily Reviews)
CREATE TABLE IF NOT EXISTS public.daily_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    log_date DATE NOT NULL,
    score_fraction TEXT NOT NULL DEFAULT '0/0',
    score_percentage DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    is_streak_qualified BOOLEAN NOT NULL DEFAULT false,
    study_hours DOUBLE PRECISION DEFAULT 0.0,
    work_hours DOUBLE PRECISION DEFAULT 0.0,
    learn_hours DOUBLE PRECISION DEFAULT 0.0,
    sleep_hours DOUBLE PRECISION DEFAULT 0.0,
    reflection_notes TEXT DEFAULT '',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    CONSTRAINT unique_user_log_date UNIQUE (user_id, log_date)
);

-- Enable RLS on Daily Logs
ALTER TABLE public.daily_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own daily logs"
    ON public.daily_logs FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE INDEX idx_daily_logs_user_date ON public.daily_logs(user_id, log_date DESC);

-- 5. Daily Habit Entries Table (Per-Habit Entry Results)
CREATE TABLE IF NOT EXISTS public.daily_habit_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    daily_log_id UUID NOT NULL REFERENCES public.daily_logs(id) ON DELETE CASCADE,
    habit_id UUID NOT NULL REFERENCES public.habits(id) ON DELETE CASCADE,
    is_passed BOOLEAN NOT NULL DEFAULT false,
    logged_value DOUBLE PRECISION,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    CONSTRAINT unique_daily_habit_entry UNIQUE (daily_log_id, habit_id)
);

-- Enable RLS on Daily Habit Entries
ALTER TABLE public.daily_habit_entries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their habit entries via daily_logs"
    ON public.daily_habit_entries FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.daily_logs
            WHERE daily_logs.id = daily_habit_entries.daily_log_id
            AND daily_logs.user_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.daily_logs
            WHERE daily_logs.id = daily_habit_entries.daily_log_id
            AND daily_logs.user_id = auth.uid()
        )
    );

-- 6. Trigger to Automatically Create Profile on Signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, full_name, created_at, updated_at)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
        now(),
        now()
    );

    -- Automatically seed default dynamic habits
    INSERT INTO public.habits (user_id, title, category, habit_type, unit, target_min, target_max, order_index, is_active)
    VALUES
        (NEW.id, 'Sleep Duration (7.0 - 8.5 hrs)', 'sleep', 'numeric_range', 'hrs', 7.0, 8.5, 1, true),
        (NEW.id, 'Work Focus Time (>= 4.0 hrs)', 'productivity', 'numeric_min', 'hrs', 4.0, NULL, 2, true),
        (NEW.id, 'Study Focus Time (>= 2.0 hrs)', 'productivity', 'numeric_min', 'hrs', 2.0, NULL, 3, true),
        (NEW.id, 'Learn New Skills (>= 1.0 hr)', 'productivity', 'numeric_min', 'hrs', 1.0, NULL, 4, true),
        (NEW.id, 'Physical Workout / Exercise', 'health', 'boolean', '', NULL, NULL, 5, true),
        (NEW.id, 'Hydration (3L+ Water)', 'health', 'boolean', '', NULL, NULL, 6, true),
        (NEW.id, 'Clean Nutrition & No Sugar', 'health', 'boolean', '', NULL, NULL, 7, true),
        (NEW.id, 'Read 20+ Pages of Book', 'mindset', 'boolean', '', NULL, NULL, 8, true),
        (NEW.id, 'Mindfulness & Meditation', 'mindset', 'boolean', '', NULL, NULL, 9, true),
        (NEW.id, 'No Screen 1hr Before Bed', 'mindset', 'boolean', '', NULL, NULL, 10, true);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Attach Trigger to auth.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
