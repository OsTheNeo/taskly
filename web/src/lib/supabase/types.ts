// Tipos generados para la base de datos de Taskly

export type RecurrenceFrequency = 'once' | 'daily' | 'weekly' | 'biweekly' | 'monthly' | 'yearly';
export type TaskType = 'goal' | 'task' | 'chore';
export type CompletionStatus = 'pending' | 'partial' | 'completed' | 'skipped';
export type HouseholdRole = 'owner' | 'admin' | 'member';

export interface Profile {
  id: string;
  firebase_uid: string;
  email: string | null;
  display_name: string | null;
  avatar_url: string | null;
  timezone: string;
  daily_reset_hour: number;
  week_starts_on: number;
  notification_enabled: boolean;
  created_at: string;
  updated_at: string;
}

export interface Task {
  id: string;
  user_id: string | null;
  household_id: string | null;
  title: string;
  description: string | null;
  icon: string | null;
  color: string | null;
  task_type: TaskType;
  recurrence: RecurrenceFrequency;
  recurrence_days: number[] | null;
  recurrence_interval: number;
  has_progress: boolean;
  progress_unit: string | null;
  progress_target: number | null;
  start_date: string;
  end_date: string | null;
  is_active: boolean;
  is_archived: boolean;
  sort_order: number;
  created_at: string;
  updated_at: string;
}

export interface TaskCompletion {
  id: string;
  task_id: string;
  completed_by: string | null;
  completion_date: string;
  status: CompletionStatus;
  progress_value: number | null;
  notes: string | null;
  completed_at: string;
}

export interface Household {
  id: string;
  name: string;
  description: string | null;
  invite_code: string;
  created_by: string | null;
  created_at: string;
  updated_at: string;
}

export interface HouseholdMember {
  id: string;
  household_id: string;
  user_id: string;
  role: HouseholdRole;
  nickname: string | null;
  joined_at: string;
}

export interface TaskAssignment {
  id: string;
  task_id: string;
  user_id: string;
  assigned_date: string | null;
  assigned_at: string;
  assigned_by: string | null;
}

export interface DailySummary {
  id: string;
  user_id: string;
  summary_date: string;
  total_tasks: number;
  completed_tasks: number;
  partial_tasks: number;
  skipped_tasks: number;
  total_goals: number;
  completed_goals: number;
  current_streak: number;
  created_at: string;
  updated_at: string;
}

export interface Category {
  id: string;
  user_id: string;
  name: string;
  icon: string | null;
  color: string | null;
  sort_order: number;
  created_at: string;
}

// Tipo para la base de datos completa
export interface Database {
  public: {
    Tables: {
      taskly_profiles: {
        Row: Profile;
        Insert: Omit<Profile, 'created_at' | 'updated_at'> & {
          created_at?: string;
          updated_at?: string;
        };
        Update: Partial<Profile>;
      };
      taskly_tasks: {
        Row: Task;
        Insert: Omit<Task, 'id' | 'created_at' | 'updated_at' | 'sort_order'> & {
          id?: string;
          created_at?: string;
          updated_at?: string;
          sort_order?: number;
        };
        Update: Partial<Task>;
      };
      taskly_task_completions: {
        Row: TaskCompletion;
        Insert: Omit<TaskCompletion, 'id' | 'completed_at'> & {
          id?: string;
          completed_at?: string;
        };
        Update: Partial<TaskCompletion>;
      };
      taskly_households: {
        Row: Household;
        Insert: Omit<Household, 'id' | 'invite_code' | 'created_at' | 'updated_at'> & {
          id?: string;
          invite_code?: string;
          created_at?: string;
          updated_at?: string;
        };
        Update: Partial<Household>;
      };
      taskly_household_members: {
        Row: HouseholdMember;
        Insert: Omit<HouseholdMember, 'id' | 'joined_at'> & {
          id?: string;
          joined_at?: string;
        };
        Update: Partial<HouseholdMember>;
      };
      taskly_task_assignments: {
        Row: TaskAssignment;
        Insert: Omit<TaskAssignment, 'id' | 'assigned_at'> & {
          id?: string;
          assigned_at?: string;
        };
        Update: Partial<TaskAssignment>;
      };
      taskly_daily_summaries: {
        Row: DailySummary;
        Insert: Omit<DailySummary, 'id' | 'created_at' | 'updated_at'> & {
          id?: string;
          created_at?: string;
          updated_at?: string;
        };
        Update: Partial<DailySummary>;
      };
      taskly_categories: {
        Row: Category;
        Insert: Omit<Category, 'id' | 'created_at' | 'sort_order'> & {
          id?: string;
          created_at?: string;
          sort_order?: number;
        };
        Update: Partial<Category>;
      };
    };
  };
}

// Tipos de UI para la aplicación
export interface TaskWithCompletion extends Task {
  completion?: TaskCompletion | null;
}

export interface CreateTaskInput {
  title: string;
  description?: string;
  icon?: string;
  color?: string;
  task_type?: TaskType;
  recurrence?: RecurrenceFrequency;
  recurrence_days?: number[];
  has_progress?: boolean;
  progress_unit?: string;
  progress_target?: number;
}

export interface UpdateTaskInput {
  title?: string;
  description?: string;
  is_active?: boolean;
  is_archived?: boolean;
  sort_order?: number;
}
