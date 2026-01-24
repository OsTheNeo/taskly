-- ============================================================================
-- TASKLY DATABASE SCHEMA (dentro del proyecto portfolio)
-- Todas las tablas tienen prefijo taskly_ para evitar conflictos
-- ============================================================================

-- Enable necessary extensions in extensions schema
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA extensions;
CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA extensions;

-- Set search path to include extensions
SET search_path TO public, extensions;

-- ============================================================================
-- ENUM TYPES (con prefijo taskly_)
-- ============================================================================

DO $$ BEGIN
    CREATE TYPE taskly_recurrence_frequency AS ENUM (
        'once', 'daily', 'weekly', 'biweekly', 'monthly', 'yearly'
    );
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE taskly_task_type AS ENUM (
        'goal', 'task', 'chore'
    );
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE taskly_completion_status AS ENUM (
        'pending', 'partial', 'completed', 'skipped'
    );
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE taskly_household_role AS ENUM (
        'owner', 'admin', 'member'
    );
EXCEPTION WHEN duplicate_object THEN null;
END $$;

-- ============================================================================
-- TABLE: taskly_profiles (Usuarios)
-- ============================================================================

CREATE TABLE IF NOT EXISTS taskly_profiles (
    id UUID PRIMARY KEY,
    firebase_uid TEXT UNIQUE NOT NULL,
    email TEXT,
    display_name TEXT,
    avatar_url TEXT,
    timezone TEXT DEFAULT 'America/New_York',
    daily_reset_hour INTEGER DEFAULT 0 CHECK (daily_reset_hour >= 0 AND daily_reset_hour <= 23),
    week_starts_on INTEGER DEFAULT 1 CHECK (week_starts_on >= 0 AND week_starts_on <= 6),
    notification_enabled BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_taskly_profiles_firebase_uid ON taskly_profiles(firebase_uid);
CREATE INDEX IF NOT EXISTS idx_taskly_profiles_email ON taskly_profiles(email);

-- ============================================================================
-- TABLE: taskly_households (Hogares/Grupos)
-- ============================================================================

CREATE TABLE IF NOT EXISTS taskly_households (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    invite_code TEXT UNIQUE DEFAULT encode(gen_random_bytes(6), 'hex'),
    created_by UUID REFERENCES taskly_profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_taskly_households_invite_code ON taskly_households(invite_code);

-- ============================================================================
-- TABLE: taskly_household_members
-- ============================================================================

CREATE TABLE IF NOT EXISTS taskly_household_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    household_id UUID NOT NULL REFERENCES taskly_households(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES taskly_profiles(id) ON DELETE CASCADE,
    role taskly_household_role DEFAULT 'member' NOT NULL,
    nickname TEXT,
    joined_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    UNIQUE(household_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_taskly_household_members_user ON taskly_household_members(user_id);
CREATE INDEX IF NOT EXISTS idx_taskly_household_members_household ON taskly_household_members(household_id);

-- ============================================================================
-- TABLE: taskly_tasks (Tareas y Metas)
-- ============================================================================

CREATE TABLE IF NOT EXISTS taskly_tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES taskly_profiles(id) ON DELETE CASCADE,
    household_id UUID REFERENCES taskly_households(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    icon TEXT,
    color TEXT,
    task_type taskly_task_type DEFAULT 'task' NOT NULL,
    recurrence taskly_recurrence_frequency DEFAULT 'once' NOT NULL,
    recurrence_days INTEGER[] DEFAULT NULL,
    recurrence_interval INTEGER DEFAULT 1,
    has_progress BOOLEAN DEFAULT false,
    progress_unit TEXT,
    progress_target NUMERIC,
    start_date DATE DEFAULT CURRENT_DATE,
    end_date DATE,
    is_active BOOLEAN DEFAULT true,
    is_archived BOOLEAN DEFAULT false,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    CONSTRAINT taskly_valid_progress CHECK (
        (has_progress = false) OR
        (has_progress = true AND progress_target IS NOT NULL AND progress_target > 0)
    ),
    CONSTRAINT taskly_valid_ownership CHECK (
        user_id IS NOT NULL OR household_id IS NOT NULL
    )
);

CREATE INDEX IF NOT EXISTS idx_taskly_tasks_user ON taskly_tasks(user_id) WHERE user_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_taskly_tasks_household ON taskly_tasks(household_id) WHERE household_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_taskly_tasks_type ON taskly_tasks(task_type);
CREATE INDEX IF NOT EXISTS idx_taskly_tasks_active ON taskly_tasks(is_active, is_archived);

-- ============================================================================
-- TABLE: taskly_task_completions
-- ============================================================================

CREATE TABLE IF NOT EXISTS taskly_task_completions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id UUID NOT NULL REFERENCES taskly_tasks(id) ON DELETE CASCADE,
    completed_by UUID REFERENCES taskly_profiles(id) ON DELETE SET NULL,
    completion_date DATE NOT NULL DEFAULT CURRENT_DATE,
    status taskly_completion_status DEFAULT 'completed' NOT NULL,
    progress_value NUMERIC,
    notes TEXT,
    completed_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    UNIQUE(task_id, completion_date, completed_by)
);

CREATE INDEX IF NOT EXISTS idx_taskly_completions_task ON taskly_task_completions(task_id);
CREATE INDEX IF NOT EXISTS idx_taskly_completions_user ON taskly_task_completions(completed_by);
CREATE INDEX IF NOT EXISTS idx_taskly_completions_date ON taskly_task_completions(completion_date DESC);

-- ============================================================================
-- TABLE: taskly_task_assignments
-- ============================================================================

CREATE TABLE IF NOT EXISTS taskly_task_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id UUID NOT NULL REFERENCES taskly_tasks(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES taskly_profiles(id) ON DELETE CASCADE,
    assigned_date DATE,
    assigned_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    assigned_by UUID REFERENCES taskly_profiles(id) ON DELETE SET NULL,
    UNIQUE(task_id, user_id, assigned_date)
);

CREATE INDEX IF NOT EXISTS idx_taskly_assignments_task ON taskly_task_assignments(task_id);
CREATE INDEX IF NOT EXISTS idx_taskly_assignments_user ON taskly_task_assignments(user_id);

-- ============================================================================
-- TABLE: taskly_daily_summaries
-- ============================================================================

CREATE TABLE IF NOT EXISTS taskly_daily_summaries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES taskly_profiles(id) ON DELETE CASCADE,
    summary_date DATE NOT NULL,
    total_tasks INTEGER DEFAULT 0,
    completed_tasks INTEGER DEFAULT 0,
    partial_tasks INTEGER DEFAULT 0,
    skipped_tasks INTEGER DEFAULT 0,
    total_goals INTEGER DEFAULT 0,
    completed_goals INTEGER DEFAULT 0,
    current_streak INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    UNIQUE(user_id, summary_date)
);

CREATE INDEX IF NOT EXISTS idx_taskly_summaries_user_date ON taskly_daily_summaries(user_id, summary_date DESC);

-- ============================================================================
-- TABLE: taskly_categories (Categorías personalizadas)
-- ============================================================================

CREATE TABLE IF NOT EXISTS taskly_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES taskly_profiles(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    icon TEXT,
    color TEXT,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_taskly_categories_user ON taskly_categories(user_id);

-- ============================================================================
-- FUNCTIONS & TRIGGERS
-- ============================================================================

CREATE OR REPLACE FUNCTION taskly_update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers para updated_at
DROP TRIGGER IF EXISTS taskly_profiles_updated_at ON taskly_profiles;
CREATE TRIGGER taskly_profiles_updated_at
    BEFORE UPDATE ON taskly_profiles
    FOR EACH ROW EXECUTE FUNCTION taskly_update_updated_at();

DROP TRIGGER IF EXISTS taskly_households_updated_at ON taskly_households;
CREATE TRIGGER taskly_households_updated_at
    BEFORE UPDATE ON taskly_households
    FOR EACH ROW EXECUTE FUNCTION taskly_update_updated_at();

DROP TRIGGER IF EXISTS taskly_tasks_updated_at ON taskly_tasks;
CREATE TRIGGER taskly_tasks_updated_at
    BEFORE UPDATE ON taskly_tasks
    FOR EACH ROW EXECUTE FUNCTION taskly_update_updated_at();

DROP TRIGGER IF EXISTS taskly_daily_summaries_updated_at ON taskly_daily_summaries;
CREATE TRIGGER taskly_daily_summaries_updated_at
    BEFORE UPDATE ON taskly_daily_summaries
    FOR EACH ROW EXECUTE FUNCTION taskly_update_updated_at();

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================

ALTER TABLE taskly_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE taskly_households ENABLE ROW LEVEL SECURITY;
ALTER TABLE taskly_household_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE taskly_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE taskly_task_completions ENABLE ROW LEVEL SECURITY;
ALTER TABLE taskly_task_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE taskly_daily_summaries ENABLE ROW LEVEL SECURITY;
ALTER TABLE taskly_categories ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- RLS POLICIES: taskly_profiles
-- Nota: Usamos firebase_uid para identificar usuarios via JWT custom claim
-- ============================================================================

-- Policy para servicio (service_role puede todo)
CREATE POLICY "Service role full access on taskly_profiles"
    ON taskly_profiles FOR ALL
    USING (true)
    WITH CHECK (true);

-- ============================================================================
-- RLS POLICIES: taskly_tasks
-- ============================================================================

CREATE POLICY "Service role full access on taskly_tasks"
    ON taskly_tasks FOR ALL
    USING (true)
    WITH CHECK (true);

-- ============================================================================
-- RLS POLICIES: taskly_task_completions
-- ============================================================================

CREATE POLICY "Service role full access on taskly_task_completions"
    ON taskly_task_completions FOR ALL
    USING (true)
    WITH CHECK (true);

-- ============================================================================
-- RLS POLICIES: taskly_households
-- ============================================================================

CREATE POLICY "Service role full access on taskly_households"
    ON taskly_households FOR ALL
    USING (true)
    WITH CHECK (true);

-- ============================================================================
-- RLS POLICIES: taskly_household_members
-- ============================================================================

CREATE POLICY "Service role full access on taskly_household_members"
    ON taskly_household_members FOR ALL
    USING (true)
    WITH CHECK (true);

-- ============================================================================
-- RLS POLICIES: taskly_task_assignments
-- ============================================================================

CREATE POLICY "Service role full access on taskly_task_assignments"
    ON taskly_task_assignments FOR ALL
    USING (true)
    WITH CHECK (true);

-- ============================================================================
-- RLS POLICIES: taskly_daily_summaries
-- ============================================================================

CREATE POLICY "Service role full access on taskly_daily_summaries"
    ON taskly_daily_summaries FOR ALL
    USING (true)
    WITH CHECK (true);

-- ============================================================================
-- RLS POLICIES: taskly_categories
-- ============================================================================

CREATE POLICY "Service role full access on taskly_categories"
    ON taskly_categories FOR ALL
    USING (true)
    WITH CHECK (true);

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON TABLE taskly_profiles IS 'Perfiles de usuario de Taskly (sincronizado con Firebase Auth)';
COMMENT ON TABLE taskly_households IS 'Hogares/grupos para compartir tareas';
COMMENT ON TABLE taskly_tasks IS 'Tareas, metas diarias y tareas del hogar';
COMMENT ON TABLE taskly_task_completions IS 'Registro historico de completados';
COMMENT ON TABLE taskly_categories IS 'Categorias personalizadas de usuarios';
