-- ============================================================================
-- TASKLY DATABASE SCHEMA
-- App de seguimiento de metas diarias y tareas del hogar
-- ============================================================================

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- ENUM TYPES
-- ============================================================================

-- Frecuencia de recurrencia para tareas
CREATE TYPE recurrence_frequency AS ENUM (
    'once',       -- Tarea unica (no recurrente)
    'daily',      -- Todos los dias
    'weekly',     -- Semanal
    'biweekly',   -- Cada 2 semanas
    'monthly',    -- Mensual
    'yearly'      -- Anual
);

-- Tipo de tarea
CREATE TYPE task_type AS ENUM (
    'goal',       -- Meta diaria (habito)
    'task',       -- Tarea normal
    'chore'       -- Tarea del hogar (puede ser compartida)
);

-- Estado de completado
CREATE TYPE completion_status AS ENUM (
    'pending',    -- Pendiente
    'partial',    -- Parcialmente completado (para tareas con progreso)
    'completed',  -- Completado
    'skipped'     -- Saltado/omitido
);

-- Rol en el hogar/grupo
CREATE TYPE household_role AS ENUM (
    'owner',      -- Creador del hogar
    'admin',      -- Administrador
    'member'      -- Miembro normal
);

-- ============================================================================
-- TABLE: profiles (Usuarios)
-- Extiende auth.users con informacion adicional del perfil
-- ============================================================================

CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT,
    display_name TEXT,
    avatar_url TEXT,
    timezone TEXT DEFAULT 'UTC',

    -- Preferencias de la app
    daily_reset_hour INTEGER DEFAULT 0 CHECK (daily_reset_hour >= 0 AND daily_reset_hour <= 23),
    week_starts_on INTEGER DEFAULT 1 CHECK (week_starts_on >= 0 AND week_starts_on <= 6), -- 0=domingo, 1=lunes
    notification_enabled BOOLEAN DEFAULT true,

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Index para busquedas por email
CREATE INDEX idx_profiles_email ON profiles(email);

-- ============================================================================
-- TABLE: households (Hogares/Grupos)
-- Grupos para compartir tareas entre multiples usuarios
-- ============================================================================

CREATE TABLE households (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    description TEXT,
    invite_code TEXT UNIQUE DEFAULT encode(gen_random_bytes(6), 'hex'),

    -- Quien creo el hogar
    created_by UUID REFERENCES profiles(id) ON DELETE SET NULL,

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Index para busqueda por codigo de invitacion
CREATE INDEX idx_households_invite_code ON households(invite_code);

-- ============================================================================
-- TABLE: household_members (Miembros del hogar)
-- Relacion muchos-a-muchos entre usuarios y hogares
-- ============================================================================

CREATE TABLE household_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    household_id UUID NOT NULL REFERENCES households(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    role household_role DEFAULT 'member' NOT NULL,
    nickname TEXT, -- Nombre opcional dentro del hogar

    -- Timestamps
    joined_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,

    -- Un usuario solo puede estar una vez en cada hogar
    UNIQUE(household_id, user_id)
);

-- Indices para queries comunes
CREATE INDEX idx_household_members_user ON household_members(user_id);
CREATE INDEX idx_household_members_household ON household_members(household_id);

-- ============================================================================
-- TABLE: tasks (Tareas y Metas)
-- Tabla principal de tareas, metas diarias y tareas del hogar
-- ============================================================================

CREATE TABLE tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    -- Propietario (puede ser null si es tarea de hogar sin asignar)
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,

    -- Si es tarea compartida, pertenece a un hogar
    household_id UUID REFERENCES households(id) ON DELETE CASCADE,

    -- Informacion basica
    title TEXT NOT NULL,
    description TEXT,
    icon TEXT, -- Emoji o nombre de icono
    color TEXT, -- Color hex para la UI

    -- Tipo y recurrencia
    task_type task_type DEFAULT 'task' NOT NULL,
    recurrence recurrence_frequency DEFAULT 'once' NOT NULL,

    -- Configuracion de recurrencia avanzada
    recurrence_days INTEGER[] DEFAULT NULL, -- Dias especificos: [1,3,5] = lun, mie, vie (para weekly)
    recurrence_interval INTEGER DEFAULT 1, -- Cada cuantos periodos (ej: cada 2 semanas)

    -- Para tareas con progreso medible
    has_progress BOOLEAN DEFAULT false,
    progress_unit TEXT, -- ej: "minutos", "paginas", "vasos"
    progress_target NUMERIC, -- ej: 30 (minutos), 10 (paginas)

    -- Fechas
    start_date DATE DEFAULT CURRENT_DATE,
    end_date DATE, -- NULL = sin fecha fin

    -- Estado
    is_active BOOLEAN DEFAULT true,
    is_archived BOOLEAN DEFAULT false,

    -- Orden en la lista
    sort_order INTEGER DEFAULT 0,

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,

    -- Validaciones
    CONSTRAINT valid_progress CHECK (
        (has_progress = false) OR
        (has_progress = true AND progress_target IS NOT NULL AND progress_target > 0)
    ),
    CONSTRAINT valid_ownership CHECK (
        user_id IS NOT NULL OR household_id IS NOT NULL
    ),
    CONSTRAINT valid_recurrence_days CHECK (
        recurrence_days IS NULL OR
        (array_length(recurrence_days, 1) > 0 AND
         recurrence_days <@ ARRAY[0,1,2,3,4,5,6])
    )
);

-- Indices para queries comunes
CREATE INDEX idx_tasks_user ON tasks(user_id) WHERE user_id IS NOT NULL;
CREATE INDEX idx_tasks_household ON tasks(household_id) WHERE household_id IS NOT NULL;
CREATE INDEX idx_tasks_type ON tasks(task_type);
CREATE INDEX idx_tasks_active ON tasks(is_active, is_archived);
CREATE INDEX idx_tasks_start_date ON tasks(start_date);

-- ============================================================================
-- TABLE: task_completions (Registro de completados/progreso)
-- Historial de cuando se completan las tareas
-- ============================================================================

CREATE TABLE task_completions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,

    -- Quien completo la tarea (importante para tareas compartidas)
    completed_by UUID REFERENCES profiles(id) ON DELETE SET NULL,

    -- Fecha del registro (sin hora, para agrupar por dia)
    completion_date DATE NOT NULL DEFAULT CURRENT_DATE,

    -- Estado
    status completion_status DEFAULT 'completed' NOT NULL,

    -- Progreso (si la tarea tiene has_progress = true)
    progress_value NUMERIC, -- Cuanto progreso se hizo

    -- Notas opcionales
    notes TEXT,

    -- Timestamp exacto de cuando se registro
    completed_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,

    -- Una tarea solo puede tener un registro por dia por usuario
    UNIQUE(task_id, completion_date, completed_by)
);

-- Indices para queries de historial
CREATE INDEX idx_completions_task ON task_completions(task_id);
CREATE INDEX idx_completions_user ON task_completions(completed_by);
CREATE INDEX idx_completions_date ON task_completions(completion_date DESC);
CREATE INDEX idx_completions_task_date ON task_completions(task_id, completion_date DESC);

-- ============================================================================
-- TABLE: task_assignments (Asignaciones de tareas compartidas)
-- Quien esta asignado a tareas de hogar
-- ============================================================================

CREATE TABLE task_assignments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,

    -- Puede asignarse para una fecha especifica o ser permanente
    assigned_date DATE, -- NULL = asignacion permanente

    -- Timestamps
    assigned_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    assigned_by UUID REFERENCES profiles(id) ON DELETE SET NULL,

    -- Evitar duplicados
    UNIQUE(task_id, user_id, assigned_date)
);

-- Indices
CREATE INDEX idx_assignments_task ON task_assignments(task_id);
CREATE INDEX idx_assignments_user ON task_assignments(user_id);
CREATE INDEX idx_assignments_date ON task_assignments(assigned_date);

-- ============================================================================
-- TABLE: daily_summaries (Resumen diario - cache/agregacion)
-- Para mostrar estadisticas rapidas sin calcular cada vez
-- ============================================================================

CREATE TABLE daily_summaries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    summary_date DATE NOT NULL,

    -- Estadisticas del dia
    total_tasks INTEGER DEFAULT 0,
    completed_tasks INTEGER DEFAULT 0,
    partial_tasks INTEGER DEFAULT 0,
    skipped_tasks INTEGER DEFAULT 0,

    -- Metas especificamente
    total_goals INTEGER DEFAULT 0,
    completed_goals INTEGER DEFAULT 0,

    -- Streak actual (dias consecutivos cumpliendo metas)
    current_streak INTEGER DEFAULT 0,

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,

    UNIQUE(user_id, summary_date)
);

-- Indices
CREATE INDEX idx_summaries_user_date ON daily_summaries(user_id, summary_date DESC);

-- ============================================================================
-- FUNCTIONS & TRIGGERS
-- ============================================================================

-- Funcion para actualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers para updated_at
CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_households_updated_at
    BEFORE UPDATE ON households
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tasks_updated_at
    BEFORE UPDATE ON tasks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_daily_summaries_updated_at
    BEFORE UPDATE ON daily_summaries
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Funcion para crear perfil automaticamente cuando se registra usuario
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO profiles (id, email, display_name)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(NEW.email, '@', 1))
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger para crear perfil en registro
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================

-- Habilitar RLS en todas las tablas
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE households ENABLE ROW LEVEL SECURITY;
ALTER TABLE household_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE task_completions ENABLE ROW LEVEL SECURITY;
ALTER TABLE task_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_summaries ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- RLS POLICIES: profiles
-- ============================================================================

-- Los usuarios pueden ver su propio perfil
CREATE POLICY "Users can view own profile"
    ON profiles FOR SELECT
    USING (auth.uid() = id);

-- Los usuarios pueden actualizar su propio perfil
CREATE POLICY "Users can update own profile"
    ON profiles FOR UPDATE
    USING (auth.uid() = id);

-- Los usuarios pueden ver perfiles de miembros de sus hogares
CREATE POLICY "Users can view household members profiles"
    ON profiles FOR SELECT
    USING (
        id IN (
            SELECT hm2.user_id
            FROM household_members hm1
            JOIN household_members hm2 ON hm1.household_id = hm2.household_id
            WHERE hm1.user_id = auth.uid()
        )
    );

-- ============================================================================
-- RLS POLICIES: households
-- ============================================================================

-- Los miembros pueden ver su hogar
CREATE POLICY "Household members can view their household"
    ON households FOR SELECT
    USING (
        id IN (
            SELECT household_id FROM household_members WHERE user_id = auth.uid()
        )
    );

-- Cualquier usuario autenticado puede crear un hogar
CREATE POLICY "Authenticated users can create households"
    ON households FOR INSERT
    WITH CHECK (auth.uid() IS NOT NULL);

-- Solo owner/admin puede actualizar el hogar
CREATE POLICY "Owners and admins can update household"
    ON households FOR UPDATE
    USING (
        id IN (
            SELECT household_id FROM household_members
            WHERE user_id = auth.uid() AND role IN ('owner', 'admin')
        )
    );

-- Solo owner puede eliminar el hogar
CREATE POLICY "Only owner can delete household"
    ON households FOR DELETE
    USING (
        id IN (
            SELECT household_id FROM household_members
            WHERE user_id = auth.uid() AND role = 'owner'
        )
    );

-- ============================================================================
-- RLS POLICIES: household_members
-- ============================================================================

-- Miembros pueden ver otros miembros de su hogar
CREATE POLICY "Members can view their household members"
    ON household_members FOR SELECT
    USING (
        household_id IN (
            SELECT household_id FROM household_members WHERE user_id = auth.uid()
        )
    );

-- Owner/admin puede agregar miembros
CREATE POLICY "Owners and admins can add members"
    ON household_members FOR INSERT
    WITH CHECK (
        household_id IN (
            SELECT household_id FROM household_members
            WHERE user_id = auth.uid() AND role IN ('owner', 'admin')
        )
        OR
        -- O el usuario se esta agregando a si mismo (via invite code)
        user_id = auth.uid()
    );

-- Owner/admin puede actualizar roles (excepto su propio rol si es owner)
CREATE POLICY "Owners and admins can update member roles"
    ON household_members FOR UPDATE
    USING (
        household_id IN (
            SELECT household_id FROM household_members
            WHERE user_id = auth.uid() AND role IN ('owner', 'admin')
        )
    );

-- Miembros pueden eliminarse a si mismos, owner/admin puede eliminar otros
CREATE POLICY "Members can leave or be removed by admins"
    ON household_members FOR DELETE
    USING (
        user_id = auth.uid()
        OR
        household_id IN (
            SELECT household_id FROM household_members
            WHERE user_id = auth.uid() AND role IN ('owner', 'admin')
        )
    );

-- ============================================================================
-- RLS POLICIES: tasks
-- ============================================================================

-- Usuarios pueden ver sus propias tareas
CREATE POLICY "Users can view own tasks"
    ON tasks FOR SELECT
    USING (user_id = auth.uid());

-- Usuarios pueden ver tareas de sus hogares
CREATE POLICY "Users can view household tasks"
    ON tasks FOR SELECT
    USING (
        household_id IN (
            SELECT household_id FROM household_members WHERE user_id = auth.uid()
        )
    );

-- Usuarios pueden crear sus propias tareas
CREATE POLICY "Users can create own tasks"
    ON tasks FOR INSERT
    WITH CHECK (
        user_id = auth.uid()
        OR
        -- O crear tareas para un hogar del que son miembros
        household_id IN (
            SELECT household_id FROM household_members WHERE user_id = auth.uid()
        )
    );

-- Usuarios pueden actualizar sus propias tareas
CREATE POLICY "Users can update own tasks"
    ON tasks FOR UPDATE
    USING (user_id = auth.uid());

-- Miembros pueden actualizar tareas de su hogar
CREATE POLICY "Members can update household tasks"
    ON tasks FOR UPDATE
    USING (
        household_id IN (
            SELECT household_id FROM household_members WHERE user_id = auth.uid()
        )
    );

-- Usuarios pueden eliminar sus propias tareas
CREATE POLICY "Users can delete own tasks"
    ON tasks FOR DELETE
    USING (user_id = auth.uid());

-- Owner/admin pueden eliminar tareas del hogar
CREATE POLICY "Admins can delete household tasks"
    ON tasks FOR DELETE
    USING (
        household_id IN (
            SELECT household_id FROM household_members
            WHERE user_id = auth.uid() AND role IN ('owner', 'admin')
        )
    );

-- ============================================================================
-- RLS POLICIES: task_completions
-- ============================================================================

-- Usuarios pueden ver completados de sus tareas
CREATE POLICY "Users can view own task completions"
    ON task_completions FOR SELECT
    USING (
        task_id IN (SELECT id FROM tasks WHERE user_id = auth.uid())
    );

-- Usuarios pueden ver completados de tareas de su hogar
CREATE POLICY "Users can view household task completions"
    ON task_completions FOR SELECT
    USING (
        task_id IN (
            SELECT id FROM tasks WHERE household_id IN (
                SELECT household_id FROM household_members WHERE user_id = auth.uid()
            )
        )
    );

-- Usuarios pueden registrar completados de sus tareas
CREATE POLICY "Users can insert own task completions"
    ON task_completions FOR INSERT
    WITH CHECK (
        completed_by = auth.uid()
        AND (
            task_id IN (SELECT id FROM tasks WHERE user_id = auth.uid())
            OR
            task_id IN (
                SELECT id FROM tasks WHERE household_id IN (
                    SELECT household_id FROM household_members WHERE user_id = auth.uid()
                )
            )
        )
    );

-- Usuarios pueden actualizar sus propios completados
CREATE POLICY "Users can update own completions"
    ON task_completions FOR UPDATE
    USING (completed_by = auth.uid());

-- Usuarios pueden eliminar sus propios completados
CREATE POLICY "Users can delete own completions"
    ON task_completions FOR DELETE
    USING (completed_by = auth.uid());

-- ============================================================================
-- RLS POLICIES: task_assignments
-- ============================================================================

-- Usuarios pueden ver asignaciones de tareas de su hogar
CREATE POLICY "Users can view household task assignments"
    ON task_assignments FOR SELECT
    USING (
        task_id IN (
            SELECT id FROM tasks WHERE household_id IN (
                SELECT household_id FROM household_members WHERE user_id = auth.uid()
            )
        )
    );

-- Miembros del hogar pueden crear asignaciones
CREATE POLICY "Members can create task assignments"
    ON task_assignments FOR INSERT
    WITH CHECK (
        task_id IN (
            SELECT id FROM tasks WHERE household_id IN (
                SELECT household_id FROM household_members WHERE user_id = auth.uid()
            )
        )
    );

-- Miembros pueden actualizar asignaciones de su hogar
CREATE POLICY "Members can update task assignments"
    ON task_assignments FOR UPDATE
    USING (
        task_id IN (
            SELECT id FROM tasks WHERE household_id IN (
                SELECT household_id FROM household_members WHERE user_id = auth.uid()
            )
        )
    );

-- Miembros pueden eliminar asignaciones de su hogar
CREATE POLICY "Members can delete task assignments"
    ON task_assignments FOR DELETE
    USING (
        task_id IN (
            SELECT id FROM tasks WHERE household_id IN (
                SELECT household_id FROM household_members WHERE user_id = auth.uid()
            )
        )
    );

-- ============================================================================
-- RLS POLICIES: daily_summaries
-- ============================================================================

-- Usuarios solo pueden ver sus propios resumenes
CREATE POLICY "Users can view own daily summaries"
    ON daily_summaries FOR SELECT
    USING (user_id = auth.uid());

-- Usuarios pueden insertar sus propios resumenes
CREATE POLICY "Users can insert own daily summaries"
    ON daily_summaries FOR INSERT
    WITH CHECK (user_id = auth.uid());

-- Usuarios pueden actualizar sus propios resumenes
CREATE POLICY "Users can update own daily summaries"
    ON daily_summaries FOR UPDATE
    USING (user_id = auth.uid());

-- ============================================================================
-- HELPFUL VIEWS (opcional, para queries comunes)
-- ============================================================================

-- Vista para tareas del dia actual con estado de completado
CREATE OR REPLACE VIEW today_tasks AS
SELECT
    t.*,
    tc.status as completion_status,
    tc.progress_value,
    tc.completed_at
FROM tasks t
LEFT JOIN task_completions tc ON t.id = tc.task_id
    AND tc.completion_date = CURRENT_DATE
    AND tc.completed_by = auth.uid()
WHERE
    t.is_active = true
    AND t.is_archived = false
    AND t.start_date <= CURRENT_DATE
    AND (t.end_date IS NULL OR t.end_date >= CURRENT_DATE)
    AND (
        t.user_id = auth.uid()
        OR t.household_id IN (
            SELECT household_id FROM household_members WHERE user_id = auth.uid()
        )
    )
ORDER BY t.sort_order, t.created_at;

-- Vista de streak actual (dias consecutivos)
CREATE OR REPLACE VIEW user_streaks AS
SELECT
    user_id,
    MAX(current_streak) as current_streak,
    COUNT(*) as total_days_tracked
FROM daily_summaries
WHERE user_id = auth.uid()
GROUP BY user_id;

-- ============================================================================
-- COMMENTS (documentacion en la base de datos)
-- ============================================================================

COMMENT ON TABLE profiles IS 'Perfiles de usuario extendiendo auth.users';
COMMENT ON TABLE households IS 'Hogares/grupos para compartir tareas';
COMMENT ON TABLE household_members IS 'Miembros de cada hogar con sus roles';
COMMENT ON TABLE tasks IS 'Tareas, metas diarias y tareas del hogar';
COMMENT ON TABLE task_completions IS 'Registro historico de completados y progreso';
COMMENT ON TABLE task_assignments IS 'Asignaciones de tareas compartidas a usuarios';
COMMENT ON TABLE daily_summaries IS 'Cache de estadisticas diarias por usuario';

COMMENT ON COLUMN tasks.recurrence_days IS 'Array de dias: 0=domingo, 1=lunes, ..., 6=sabado';
COMMENT ON COLUMN tasks.has_progress IS 'Si la tarea requiere registrar progreso numerico';
COMMENT ON COLUMN task_completions.progress_value IS 'Valor de progreso registrado (ej: 25 minutos)';
