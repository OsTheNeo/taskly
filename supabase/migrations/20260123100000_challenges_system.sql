-- ============================================================================
-- TASKLY CHALLENGES & LEADERBOARD SYSTEM
-- Sistema de retos y clasificación entre amigos/grupos
-- ============================================================================

-- Ensure pgcrypto is available
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ============================================================================
-- ENUM TYPES
-- ============================================================================

DO $$ BEGIN
    CREATE TYPE taskly_challenge_type AS ENUM (
        'streak',        -- Mantener racha de días consecutivos
        'completion',    -- Completar X tareas en un período
        'category',      -- Completar tareas de una categoría específica
        'speed',         -- Completar tareas antes de cierta hora
        'perfect_day'    -- Días con 100% de tareas completadas
    );
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE taskly_challenge_status AS ENUM (
        'upcoming',      -- Aún no empieza
        'active',        -- En progreso
        'completed',     -- Terminado
        'cancelled'      -- Cancelado
    );
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE taskly_challenge_visibility AS ENUM (
        'public',        -- Cualquiera puede unirse
        'household',     -- Solo miembros del hogar
        'invite_only'    -- Solo con código de invitación
    );
EXCEPTION WHEN duplicate_object THEN null;
END $$;

-- ============================================================================
-- TABLE: taskly_challenges (Definición de retos)
-- ============================================================================

CREATE TABLE IF NOT EXISTS taskly_challenges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Información básica
    title TEXT NOT NULL,
    description TEXT,
    emoji TEXT DEFAULT '🏆',

    -- Tipo y configuración
    challenge_type taskly_challenge_type NOT NULL,
    target_value INTEGER NOT NULL,  -- Objetivo numérico (días de racha, tareas, etc.)
    category_filter TEXT,           -- Para retos de categoría específica

    -- Duración
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,

    -- Visibilidad y permisos
    visibility taskly_challenge_visibility DEFAULT 'household' NOT NULL,
    household_id UUID REFERENCES taskly_households(id) ON DELETE CASCADE,
    invite_code TEXT UNIQUE DEFAULT substring(md5(random()::text) from 1 for 8),
    max_participants INTEGER DEFAULT 50,

    -- Estado
    status taskly_challenge_status DEFAULT 'upcoming' NOT NULL,

    -- Creador
    created_by UUID NOT NULL REFERENCES taskly_profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,

    -- Validaciones
    CONSTRAINT valid_dates CHECK (end_date >= start_date),
    CONSTRAINT valid_target CHECK (target_value > 0),
    CONSTRAINT household_visibility CHECK (
        (visibility = 'household' AND household_id IS NOT NULL) OR
        (visibility != 'household')
    )
);

CREATE INDEX IF NOT EXISTS idx_taskly_challenges_status ON taskly_challenges(status);
CREATE INDEX IF NOT EXISTS idx_taskly_challenges_dates ON taskly_challenges(start_date, end_date);
CREATE INDEX IF NOT EXISTS idx_taskly_challenges_household ON taskly_challenges(household_id) WHERE household_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_taskly_challenges_invite ON taskly_challenges(invite_code);

-- ============================================================================
-- TABLE: taskly_challenge_participants (Participantes en retos)
-- ============================================================================

CREATE TABLE IF NOT EXISTS taskly_challenge_participants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Relaciones
    challenge_id UUID NOT NULL REFERENCES taskly_challenges(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES taskly_profiles(id) ON DELETE CASCADE,

    -- Progreso
    current_score INTEGER DEFAULT 0,
    best_streak INTEGER DEFAULT 0,
    last_activity_date DATE,

    -- Estado
    is_active BOOLEAN DEFAULT true,

    -- Timestamps
    joined_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,

    UNIQUE(challenge_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_taskly_participants_challenge ON taskly_challenge_participants(challenge_id);
CREATE INDEX IF NOT EXISTS idx_taskly_participants_user ON taskly_challenge_participants(user_id);
CREATE INDEX IF NOT EXISTS idx_taskly_participants_score ON taskly_challenge_participants(challenge_id, current_score DESC);

-- ============================================================================
-- TABLE: taskly_challenge_activity (Registro de actividad diaria)
-- ============================================================================

CREATE TABLE IF NOT EXISTS taskly_challenge_activity (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    participant_id UUID NOT NULL REFERENCES taskly_challenge_participants(id) ON DELETE CASCADE,
    activity_date DATE NOT NULL,

    -- Progreso del día
    points_earned INTEGER DEFAULT 0,
    tasks_completed INTEGER DEFAULT 0,
    streak_maintained BOOLEAN DEFAULT false,

    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,

    UNIQUE(participant_id, activity_date)
);

CREATE INDEX IF NOT EXISTS idx_taskly_activity_participant ON taskly_challenge_activity(participant_id);
CREATE INDEX IF NOT EXISTS idx_taskly_activity_date ON taskly_challenge_activity(activity_date DESC);

-- ============================================================================
-- VIEW: taskly_leaderboard (Vista de clasificación)
-- ============================================================================

CREATE OR REPLACE VIEW taskly_leaderboard AS
SELECT
    cp.challenge_id,
    cp.user_id,
    p.display_name,
    p.avatar_url,
    cp.current_score,
    cp.best_streak,
    cp.last_activity_date,
    cp.joined_at,
    c.title AS challenge_title,
    c.emoji AS challenge_emoji,
    c.challenge_type,
    c.target_value,
    c.start_date,
    c.end_date,
    c.status AS challenge_status,
    RANK() OVER (
        PARTITION BY cp.challenge_id
        ORDER BY cp.current_score DESC, cp.best_streak DESC, cp.joined_at ASC
    ) AS rank,
    CASE
        WHEN cp.current_score >= c.target_value THEN true
        ELSE false
    END AS goal_reached
FROM taskly_challenge_participants cp
JOIN taskly_profiles p ON p.id = cp.user_id
JOIN taskly_challenges c ON c.id = cp.challenge_id
WHERE cp.is_active = true;

-- ============================================================================
-- VIEW: taskly_user_challenge_stats (Estadísticas de usuario)
-- ============================================================================

CREATE OR REPLACE VIEW taskly_user_challenge_stats AS
SELECT
    user_id,
    COUNT(*) FILTER (WHERE challenge_status = 'active') AS active_challenges,
    COUNT(*) FILTER (WHERE goal_reached) AS challenges_won,
    SUM(current_score) AS total_points,
    MAX(best_streak) AS all_time_best_streak,
    AVG(rank)::INTEGER AS average_rank
FROM taskly_leaderboard
GROUP BY user_id;

-- ============================================================================
-- FUNCTION: Actualizar status de challenges automáticamente
-- ============================================================================

CREATE OR REPLACE FUNCTION taskly_update_challenge_status()
RETURNS void AS $$
BEGIN
    -- Activar challenges que empiezan hoy
    UPDATE taskly_challenges
    SET status = 'active', updated_at = NOW()
    WHERE status = 'upcoming'
    AND start_date <= CURRENT_DATE;

    -- Completar challenges que terminaron
    UPDATE taskly_challenges
    SET status = 'completed', updated_at = NOW()
    WHERE status = 'active'
    AND end_date < CURRENT_DATE;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- FUNCTION: Calcular puntos del día para un participante
-- ============================================================================

CREATE OR REPLACE FUNCTION taskly_calculate_daily_points(
    p_participant_id UUID,
    p_date DATE DEFAULT CURRENT_DATE
)
RETURNS INTEGER AS $$
DECLARE
    v_challenge_type TEXT;
    v_category_filter TEXT;
    v_user_id UUID;
    v_points INTEGER := 0;
    v_tasks_completed INTEGER;
    v_streak INTEGER;
BEGIN
    -- Obtener info del participante y challenge
    SELECT cp.user_id, c.challenge_type::TEXT, c.category_filter
    INTO v_user_id, v_challenge_type, v_category_filter
    FROM taskly_challenge_participants cp
    JOIN taskly_challenges c ON c.id = cp.challenge_id
    WHERE cp.id = p_participant_id;

    IF v_user_id IS NULL THEN
        RETURN 0;
    END IF;

    -- Calcular puntos según tipo de challenge
    CASE v_challenge_type
        WHEN 'completion' THEN
            -- Puntos por cada tarea completada
            SELECT COUNT(*)
            INTO v_tasks_completed
            FROM taskly_task_completions tc
            JOIN taskly_tasks t ON t.id = tc.task_id
            WHERE tc.completed_by = v_user_id
            AND tc.completion_date = p_date
            AND tc.status = 'completed'
            AND (v_category_filter IS NULL OR t.color = v_category_filter);

            v_points := v_tasks_completed;

        WHEN 'streak' THEN
            -- 1 punto por mantener racha
            SELECT current_streak
            INTO v_streak
            FROM taskly_daily_summaries
            WHERE user_id = v_user_id
            AND summary_date = p_date;

            IF v_streak > 0 THEN
                v_points := 1;
            END IF;

        WHEN 'perfect_day' THEN
            -- 1 punto por día perfecto (100% completado)
            SELECT CASE WHEN completed_tasks = total_tasks AND total_tasks > 0 THEN 1 ELSE 0 END
            INTO v_points
            FROM taskly_daily_summaries
            WHERE user_id = v_user_id
            AND summary_date = p_date;

        WHEN 'category' THEN
            -- Puntos por tareas de categoría específica
            SELECT COUNT(*)
            INTO v_points
            FROM taskly_task_completions tc
            JOIN taskly_tasks t ON t.id = tc.task_id
            WHERE tc.completed_by = v_user_id
            AND tc.completion_date = p_date
            AND tc.status = 'completed'
            AND t.color = v_category_filter;

        ELSE
            v_points := 0;
    END CASE;

    RETURN COALESCE(v_points, 0);
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- TRIGGERS
-- ============================================================================

DROP TRIGGER IF EXISTS taskly_challenges_updated_at ON taskly_challenges;
CREATE TRIGGER taskly_challenges_updated_at
    BEFORE UPDATE ON taskly_challenges
    FOR EACH ROW EXECUTE FUNCTION taskly_update_updated_at();

DROP TRIGGER IF EXISTS taskly_participants_updated_at ON taskly_challenge_participants;
CREATE TRIGGER taskly_participants_updated_at
    BEFORE UPDATE ON taskly_challenge_participants
    FOR EACH ROW EXECUTE FUNCTION taskly_update_updated_at();

-- ============================================================================
-- ROW LEVEL SECURITY
-- ============================================================================

ALTER TABLE taskly_challenges ENABLE ROW LEVEL SECURITY;
ALTER TABLE taskly_challenge_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE taskly_challenge_activity ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Service role full access on taskly_challenges"
    ON taskly_challenges FOR ALL
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Service role full access on taskly_challenge_participants"
    ON taskly_challenge_participants FOR ALL
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Service role full access on taskly_challenge_activity"
    ON taskly_challenge_activity FOR ALL
    USING (true)
    WITH CHECK (true);

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON TABLE taskly_challenges IS 'Retos competitivos entre usuarios';
COMMENT ON TABLE taskly_challenge_participants IS 'Participantes y su progreso en retos';
COMMENT ON TABLE taskly_challenge_activity IS 'Actividad diaria de participantes';
COMMENT ON VIEW taskly_leaderboard IS 'Clasificación de participantes por reto';
COMMENT ON VIEW taskly_user_challenge_stats IS 'Estadísticas agregadas de usuario en challenges';
