// Configuración de Supabase para Taskly Web
// Proyecto: portfolio (compartido con mobile)
// Tablas con prefijo: taskly_

export const supabaseConfig = {
  url: 'https://uastktzklhwnyohgiien.supabase.co',
  anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVhc3RrdHprbGh3bnlvaGdpaWVuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY0NTQ4MTYsImV4cCI6MjA4MjAzMDgxNn0.Y_qRu9xpoMjURrbhIZn96j6L5rL_6NvE7TmlAWAI7AM',
} as const;

// Nombres de tablas con prefijo
export const tables = {
  profiles: 'taskly_profiles',
  households: 'taskly_households',
  householdMembers: 'taskly_household_members',
  tasks: 'taskly_tasks',
  taskCompletions: 'taskly_task_completions',
  taskAssignments: 'taskly_task_assignments',
  dailySummaries: 'taskly_daily_summaries',
  categories: 'taskly_categories',
} as const;
