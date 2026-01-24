/// Configuración de Supabase para Taskly
/// Proyecto: portfolio (compartido)
/// Tablas con prefijo: taskly_
class SupabaseConfig {
  static const String url = 'https://uastktzklhwnyohgiien.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVhc3RrdHprbGh3bnlvaGdpaWVuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY0NTQ4MTYsImV4cCI6MjA4MjAzMDgxNn0.Y_qRu9xpoMjURrbhIZn96j6L5rL_6NvE7TmlAWAI7AM';

  // Nombres de tablas con prefijo
  static const String profilesTable = 'taskly_profiles';
  static const String householdsTable = 'taskly_households';
  static const String householdMembersTable = 'taskly_household_members';
  static const String tasksTable = 'taskly_tasks';
  static const String taskCompletionsTable = 'taskly_task_completions';
  static const String taskAssignmentsTable = 'taskly_task_assignments';
  static const String dailySummariesTable = 'taskly_daily_summaries';
  static const String categoriesTable = 'taskly_categories';
}
