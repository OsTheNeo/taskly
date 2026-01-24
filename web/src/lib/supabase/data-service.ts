import { supabase } from './client';
import { tables } from './config';
import type {
  Profile,
  Task,
  TaskCompletion,
  Household,
  Category,
  CreateTaskInput,
  UpdateTaskInput,
  TaskWithCompletion,
} from './types';

// ============================================================================
// PROFILES
// ============================================================================

export async function upsertProfile(data: {
  firebaseUid: string;
  email?: string | null;
  displayName?: string | null;
  avatarUrl?: string | null;
}): Promise<Profile | null> {
  try {
    // Check if profile exists
    const { data: existing } = await supabase
      .from(tables.profiles)
      .select()
      .eq('firebase_uid', data.firebaseUid)
      .maybeSingle();

    if (existing) {
      // Update existing
      const { data: updated, error } = await supabase
        .from(tables.profiles)
        .update({
          email: data.email,
          display_name: data.displayName,
          avatar_url: data.avatarUrl,
        })
        .eq('firebase_uid', data.firebaseUid)
        .select()
        .single();

      if (error) throw error;
      return updated;
    } else {
      // Create new
      const { data: created, error } = await supabase
        .from(tables.profiles)
        .insert({
          id: crypto.randomUUID(),
          firebase_uid: data.firebaseUid,
          email: data.email,
          display_name: data.displayName,
          avatar_url: data.avatarUrl,
          timezone: Intl.DateTimeFormat().resolvedOptions().timeZone,
          daily_reset_hour: 0,
          week_starts_on: 1,
          notification_enabled: true,
        })
        .select()
        .single();

      if (error) throw error;
      return created;
    }
  } catch (error) {
    console.error('[DataService] Error upserting profile:', error);
    return null;
  }
}

export async function getProfile(firebaseUid: string): Promise<Profile | null> {
  try {
    const { data, error } = await supabase
      .from(tables.profiles)
      .select()
      .eq('firebase_uid', firebaseUid)
      .maybeSingle();

    if (error) throw error;
    return data;
  } catch (error) {
    console.error('[DataService] Error getting profile:', error);
    return null;
  }
}

// ============================================================================
// TASKS
// ============================================================================

export async function getTasks(firebaseUid: string): Promise<TaskWithCompletion[]> {
  try {
    const profile = await getProfile(firebaseUid);
    if (!profile) return [];

    const today = new Date().toISOString().split('T')[0];

    // Get tasks
    const { data: tasks, error: tasksError } = await supabase
      .from(tables.tasks)
      .select()
      .eq('user_id', profile.id)
      .eq('is_archived', false)
      .order('sort_order', { ascending: true });

    if (tasksError) throw tasksError;

    // Get today's completions
    const { data: completions, error: completionsError } = await supabase
      .from(tables.taskCompletions)
      .select()
      .eq('completed_by', profile.id)
      .eq('completion_date', today);

    if (completionsError) throw completionsError;

    // Merge tasks with completions
    const completionMap = new Map(completions?.map(c => [c.task_id, c]) || []);

    return (tasks || []).map(task => ({
      ...task,
      completion: completionMap.get(task.id) || null,
    }));
  } catch (error) {
    console.error('[DataService] Error getting tasks:', error);
    return [];
  }
}

export async function createTask(
  firebaseUid: string,
  input: CreateTaskInput
): Promise<Task | null> {
  try {
    const profile = await getProfile(firebaseUid);
    if (!profile) return null;

    const { data, error } = await supabase
      .from(tables.tasks)
      .insert({
        user_id: profile.id,
        title: input.title,
        description: input.description,
        icon: input.icon,
        color: input.color,
        task_type: input.task_type || 'task',
        recurrence: input.recurrence || 'once',
        recurrence_days: input.recurrence_days,
        has_progress: input.has_progress || false,
        progress_unit: input.progress_unit,
        progress_target: input.progress_target,
        start_date: new Date().toISOString().split('T')[0],
        is_active: true,
        is_archived: false,
        recurrence_interval: 1,
      })
      .select()
      .single();

    if (error) throw error;
    return data;
  } catch (error) {
    console.error('[DataService] Error creating task:', error);
    return null;
  }
}

export async function updateTask(
  taskId: string,
  input: UpdateTaskInput
): Promise<Task | null> {
  try {
    const { data, error } = await supabase
      .from(tables.tasks)
      .update(input)
      .eq('id', taskId)
      .select()
      .single();

    if (error) throw error;
    return data;
  } catch (error) {
    console.error('[DataService] Error updating task:', error);
    return null;
  }
}

export async function deleteTask(taskId: string): Promise<boolean> {
  try {
    const { error } = await supabase
      .from(tables.tasks)
      .update({ is_archived: true })
      .eq('id', taskId);

    if (error) throw error;
    return true;
  } catch (error) {
    console.error('[DataService] Error deleting task:', error);
    return false;
  }
}

// ============================================================================
// TASK COMPLETIONS
// ============================================================================

export async function completeTask(params: {
  taskId: string;
  firebaseUid: string;
  status?: 'pending' | 'partial' | 'completed' | 'skipped';
  progressValue?: number;
  notes?: string;
}): Promise<TaskCompletion | null> {
  try {
    const profile = await getProfile(params.firebaseUid);
    if (!profile) return null;

    const today = new Date().toISOString().split('T')[0];

    const { data, error } = await supabase
      .from(tables.taskCompletions)
      .upsert({
        task_id: params.taskId,
        completed_by: profile.id,
        completion_date: today,
        status: params.status || 'completed',
        progress_value: params.progressValue,
        notes: params.notes,
      }, {
        onConflict: 'task_id,completion_date,completed_by',
      })
      .select()
      .single();

    if (error) throw error;
    return data;
  } catch (error) {
    console.error('[DataService] Error completing task:', error);
    return null;
  }
}

export async function uncompleteTask(params: {
  taskId: string;
  firebaseUid: string;
}): Promise<boolean> {
  try {
    const profile = await getProfile(params.firebaseUid);
    if (!profile) return false;

    const today = new Date().toISOString().split('T')[0];

    const { error } = await supabase
      .from(tables.taskCompletions)
      .delete()
      .eq('task_id', params.taskId)
      .eq('completed_by', profile.id)
      .eq('completion_date', today);

    if (error) throw error;
    return true;
  } catch (error) {
    console.error('[DataService] Error uncompleting task:', error);
    return false;
  }
}

// ============================================================================
// HOUSEHOLDS
// ============================================================================

export async function createHousehold(params: {
  firebaseUid: string;
  name: string;
  description?: string;
}): Promise<Household | null> {
  try {
    const profile = await getProfile(params.firebaseUid);
    if (!profile) return null;

    // Create household
    const { data: household, error: householdError } = await supabase
      .from(tables.households)
      .insert({
        name: params.name,
        description: params.description,
        created_by: profile.id,
      })
      .select()
      .single();

    if (householdError) throw householdError;

    // Add creator as owner
    const { error: memberError } = await supabase
      .from(tables.householdMembers)
      .insert({
        household_id: household.id,
        user_id: profile.id,
        role: 'owner',
      });

    if (memberError) throw memberError;

    return household;
  } catch (error) {
    console.error('[DataService] Error creating household:', error);
    return null;
  }
}

export async function joinHousehold(params: {
  firebaseUid: string;
  inviteCode: string;
}): Promise<Household | null> {
  try {
    const profile = await getProfile(params.firebaseUid);
    if (!profile) return null;

    // Find household by invite code
    const { data: household, error: findError } = await supabase
      .from(tables.households)
      .select()
      .eq('invite_code', params.inviteCode)
      .maybeSingle();

    if (findError) throw findError;
    if (!household) return null;

    // Add as member
    const { error: joinError } = await supabase
      .from(tables.householdMembers)
      .insert({
        household_id: household.id,
        user_id: profile.id,
        role: 'member',
      });

    if (joinError) throw joinError;

    return household;
  } catch (error) {
    console.error('[DataService] Error joining household:', error);
    return null;
  }
}

export async function getHouseholds(firebaseUid: string): Promise<Household[]> {
  try {
    const profile = await getProfile(firebaseUid);
    if (!profile) return [];

    const { data, error } = await supabase
      .from(tables.householdMembers)
      .select(`
        household_id,
        role,
        household:${tables.households}(*)
      `)
      .eq('user_id', profile.id);

    if (error) throw error;

    return (data || [])
      .map(m => m.household as unknown as Household)
      .filter(Boolean);
  } catch (error) {
    console.error('[DataService] Error getting households:', error);
    return [];
  }
}

// ============================================================================
// CATEGORIES
// ============================================================================

export async function getCategories(firebaseUid: string): Promise<Category[]> {
  try {
    const profile = await getProfile(firebaseUid);
    if (!profile) return [];

    const { data, error } = await supabase
      .from(tables.categories)
      .select()
      .eq('user_id', profile.id)
      .order('sort_order', { ascending: true });

    if (error) throw error;
    return data || [];
  } catch (error) {
    console.error('[DataService] Error getting categories:', error);
    return [];
  }
}

export async function createCategory(params: {
  firebaseUid: string;
  name: string;
  icon?: string;
  color?: string;
}): Promise<Category | null> {
  try {
    const profile = await getProfile(params.firebaseUid);
    if (!profile) return null;

    const { data, error } = await supabase
      .from(tables.categories)
      .insert({
        user_id: profile.id,
        name: params.name,
        icon: params.icon,
        color: params.color,
      })
      .select()
      .single();

    if (error) throw error;
    return data;
  } catch (error) {
    console.error('[DataService] Error creating category:', error);
    return null;
  }
}

export async function deleteCategory(categoryId: string): Promise<boolean> {
  try {
    const { error } = await supabase
      .from(tables.categories)
      .delete()
      .eq('id', categoryId);

    if (error) throw error;
    return true;
  } catch (error) {
    console.error('[DataService] Error deleting category:', error);
    return false;
  }
}
