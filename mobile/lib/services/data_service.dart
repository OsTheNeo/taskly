import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'supabase_config.dart';

/// Servicio para sincronizar datos con Supabase
/// Usa Firebase para auth, Supabase para datos
class DataService {
  final SupabaseClient _client = Supabase.instance.client;
  final _uuid = const Uuid();

  // ============================================================================
  // PROFILES
  // ============================================================================

  /// Crea o actualiza el perfil del usuario en Supabase
  /// Se llama después del login con Firebase
  Future<Map<String, dynamic>?> upsertProfile({
    required String firebaseUid,
    required String? email,
    required String? displayName,
    String? avatarUrl,
  }) async {
    try {
      final data = {
        'id': _uuid.v4(),
        'firebase_uid': firebaseUid,
        'email': email,
        'display_name': displayName,
        'avatar_url': avatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Primero intentamos buscar si ya existe
      final existing = await _client
          .from(SupabaseConfig.profilesTable)
          .select()
          .eq('firebase_uid', firebaseUid)
          .maybeSingle();

      if (existing != null) {
        // Actualizar
        final response = await _client
            .from(SupabaseConfig.profilesTable)
            .update({
              'email': email,
              'display_name': displayName,
              'avatar_url': avatarUrl,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('firebase_uid', firebaseUid)
            .select()
            .single();
        debugPrint('[DataService] Profile updated: ${response['id']}');
        return response;
      } else {
        // Crear nuevo
        final response = await _client
            .from(SupabaseConfig.profilesTable)
            .insert(data)
            .select()
            .single();
        debugPrint('[DataService] Profile created: ${response['id']}');
        return response;
      }
    } catch (e) {
      debugPrint('[DataService] Error upserting profile: $e');
      return null;
    }
  }

  /// Obtiene el perfil del usuario por Firebase UID
  Future<Map<String, dynamic>?> getProfile(String firebaseUid) async {
    try {
      final response = await _client
          .from(SupabaseConfig.profilesTable)
          .select()
          .eq('firebase_uid', firebaseUid)
          .maybeSingle();
      return response;
    } catch (e) {
      debugPrint('[DataService] Error getting profile: $e');
      return null;
    }
  }

  // ============================================================================
  // TASKS
  // ============================================================================

  /// Obtiene todas las tareas del usuario
  Future<List<Map<String, dynamic>>> getTasks(String visitorId) async {
    try {
      final profile = await getProfile(visitorId);
      if (profile == null) return [];

      final response = await _client
          .from(SupabaseConfig.tasksTable)
          .select()
          .eq('user_id', profile['id'])
          .eq('is_archived', false)
          .order('sort_order', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('[DataService] Error getting tasks: $e');
      return [];
    }
  }

  /// Crea una nueva tarea
  Future<Map<String, dynamic>?> createTask({
    required String visitorId,
    required String title,
    String? description,
    String? icon,
    String? color,
    String taskType = 'task',
    String recurrence = 'once',
    List<int>? recurrenceDays,
    bool hasProgress = false,
    String? progressUnit,
    double? progressTarget,
    String? categoryId,
  }) async {
    try {
      final profile = await getProfile(visitorId);
      if (profile == null) {
        debugPrint('[DataService] No profile found for user');
        return null;
      }

      final data = {
        'id': _uuid.v4(),
        'user_id': profile['id'],
        'title': title,
        'description': description,
        'icon': icon,
        'color': color,
        'task_type': taskType,
        'recurrence': recurrence,
        'recurrence_days': recurrenceDays,
        'has_progress': hasProgress,
        'progress_unit': progressUnit,
        'progress_target': progressTarget,
      };

      final response = await _client
          .from(SupabaseConfig.tasksTable)
          .insert(data)
          .select()
          .single();

      debugPrint('[DataService] Task created: ${response['id']}');
      return response;
    } catch (e) {
      debugPrint('[DataService] Error creating task: $e');
      return null;
    }
  }

  /// Actualiza una tarea existente
  Future<Map<String, dynamic>?> updateTask({
    required String taskId,
    String? title,
    String? description,
    bool? isActive,
    bool? isArchived,
    int? sortOrder,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (title != null) updates['title'] = title;
      if (description != null) updates['description'] = description;
      if (isActive != null) updates['is_active'] = isActive;
      if (isArchived != null) updates['is_archived'] = isArchived;
      if (sortOrder != null) updates['sort_order'] = sortOrder;

      final response = await _client
          .from(SupabaseConfig.tasksTable)
          .update(updates)
          .eq('id', taskId)
          .select()
          .single();

      debugPrint('[DataService] Task updated: $taskId');
      return response;
    } catch (e) {
      debugPrint('[DataService] Error updating task: $e');
      return null;
    }
  }

  /// Elimina una tarea (soft delete - archiva)
  Future<bool> deleteTask(String taskId) async {
    try {
      await _client
          .from(SupabaseConfig.tasksTable)
          .update({'is_archived': true})
          .eq('id', taskId);

      debugPrint('[DataService] Task archived: $taskId');
      return true;
    } catch (e) {
      debugPrint('[DataService] Error deleting task: $e');
      return false;
    }
  }

  // ============================================================================
  // TASK COMPLETIONS
  // ============================================================================

  /// Registra el completado de una tarea
  Future<Map<String, dynamic>?> completeTask({
    required String taskId,
    required String visitorId,
    String status = 'completed',
    double? progressValue,
    String? notes,
    DateTime? date,
  }) async {
    try {
      final profile = await getProfile(visitorId);
      if (profile == null) return null;

      final completionDate = date ?? DateTime.now();

      final data = {
        'id': _uuid.v4(),
        'task_id': taskId,
        'completed_by': profile['id'],
        'completion_date': completionDate.toIso8601String().split('T')[0],
        'status': status,
        'progress_value': progressValue,
        'notes': notes,
      };

      final response = await _client
          .from(SupabaseConfig.taskCompletionsTable)
          .upsert(data, onConflict: 'task_id,completion_date,completed_by')
          .select()
          .single();

      debugPrint('[DataService] Task completion recorded: ${response['id']}');
      return response;
    } catch (e) {
      debugPrint('[DataService] Error completing task: $e');
      return null;
    }
  }

  /// Obtiene los completados de hoy
  Future<List<Map<String, dynamic>>> getTodayCompletions(String visitorId) async {
    try {
      final profile = await getProfile(visitorId);
      if (profile == null) return [];

      final today = DateTime.now().toIso8601String().split('T')[0];

      final response = await _client
          .from(SupabaseConfig.taskCompletionsTable)
          .select('*, task:taskly_tasks(*)')
          .eq('completed_by', profile['id'])
          .eq('completion_date', today);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('[DataService] Error getting today completions: $e');
      return [];
    }
  }

  /// Obtiene el historial de completados de una tarea
  Future<List<Map<String, dynamic>>> getTaskHistory({
    required String taskId,
    int limit = 30,
  }) async {
    try {
      final response = await _client
          .from(SupabaseConfig.taskCompletionsTable)
          .select()
          .eq('task_id', taskId)
          .order('completion_date', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('[DataService] Error getting task history: $e');
      return [];
    }
  }

  // ============================================================================
  // CATEGORIES
  // ============================================================================

  /// Obtiene las categorías personalizadas del usuario
  Future<List<Map<String, dynamic>>> getCategories(String visitorId) async {
    try {
      final profile = await getProfile(visitorId);
      if (profile == null) return [];

      final response = await _client
          .from(SupabaseConfig.categoriesTable)
          .select()
          .eq('user_id', profile['id'])
          .order('sort_order', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('[DataService] Error getting categories: $e');
      return [];
    }
  }

  /// Crea una categoría personalizada
  Future<Map<String, dynamic>?> createCategory({
    required String visitorId,
    required String name,
    String? icon,
    String? color,
  }) async {
    try {
      final profile = await getProfile(visitorId);
      if (profile == null) return null;

      final data = {
        'id': _uuid.v4(),
        'user_id': profile['id'],
        'name': name,
        'icon': icon,
        'color': color,
      };

      final response = await _client
          .from(SupabaseConfig.categoriesTable)
          .insert(data)
          .select()
          .single();

      debugPrint('[DataService] Category created: ${response['id']}');
      return response;
    } catch (e) {
      debugPrint('[DataService] Error creating category: $e');
      return null;
    }
  }

  /// Elimina una categoría
  Future<bool> deleteCategory(String categoryId) async {
    try {
      await _client
          .from(SupabaseConfig.categoriesTable)
          .delete()
          .eq('id', categoryId);

      debugPrint('[DataService] Category deleted: $categoryId');
      return true;
    } catch (e) {
      debugPrint('[DataService] Error deleting category: $e');
      return false;
    }
  }

  // ============================================================================
  // HOUSEHOLDS (Grupos)
  // ============================================================================

  /// Crea un nuevo hogar/grupo
  Future<Map<String, dynamic>?> createHousehold({
    required String visitorId,
    required String name,
    String? description,
  }) async {
    try {
      final profile = await getProfile(visitorId);
      if (profile == null) return null;

      final householdId = _uuid.v4();

      // Crear el hogar
      final household = await _client
          .from(SupabaseConfig.householdsTable)
          .insert({
            'id': householdId,
            'name': name,
            'description': description,
            'created_by': profile['id'],
          })
          .select()
          .single();

      // Agregar al creador como owner
      await _client.from(SupabaseConfig.householdMembersTable).insert({
        'household_id': householdId,
        'user_id': profile['id'],
        'role': 'owner',
      });

      debugPrint('[DataService] Household created: $householdId');
      return household;
    } catch (e) {
      debugPrint('[DataService] Error creating household: $e');
      return null;
    }
  }

  /// Unirse a un hogar con código de invitación
  Future<Map<String, dynamic>?> joinHousehold({
    required String visitorId,
    required String inviteCode,
  }) async {
    try {
      final profile = await getProfile(visitorId);
      if (profile == null) return null;

      // Buscar el hogar por código
      final household = await _client
          .from(SupabaseConfig.householdsTable)
          .select()
          .eq('invite_code', inviteCode)
          .maybeSingle();

      if (household == null) {
        debugPrint('[DataService] Household not found with code: $inviteCode');
        return null;
      }

      // Agregar como miembro
      await _client.from(SupabaseConfig.householdMembersTable).insert({
        'household_id': household['id'],
        'user_id': profile['id'],
        'role': 'member',
      });

      debugPrint('[DataService] Joined household: ${household['id']}');
      return household;
    } catch (e) {
      debugPrint('[DataService] Error joining household: $e');
      return null;
    }
  }

  /// Obtiene los hogares del usuario
  Future<List<Map<String, dynamic>>> getHouseholds(String visitorId) async {
    try {
      final profile = await getProfile(visitorId);
      if (profile == null) return [];

      final memberships = await _client
          .from(SupabaseConfig.householdMembersTable)
          .select('household_id, role, household:taskly_households(*)')
          .eq('user_id', profile['id']);

      return List<Map<String, dynamic>>.from(memberships);
    } catch (e) {
      debugPrint('[DataService] Error getting households: $e');
      return [];
    }
  }

  // ============================================================================
  // DAILY SUMMARY
  // ============================================================================

  /// Actualiza el resumen diario del usuario
  Future<void> updateDailySummary({
    required String visitorId,
    required int totalTasks,
    required int completedTasks,
    required int totalGoals,
    required int completedGoals,
  }) async {
    try {
      final profile = await getProfile(visitorId);
      if (profile == null) return;

      final today = DateTime.now().toIso8601String().split('T')[0];

      await _client.from(SupabaseConfig.dailySummariesTable).upsert({
        'user_id': profile['id'],
        'summary_date': today,
        'total_tasks': totalTasks,
        'completed_tasks': completedTasks,
        'total_goals': totalGoals,
        'completed_goals': completedGoals,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id,summary_date');

      debugPrint('[DataService] Daily summary updated');
    } catch (e) {
      debugPrint('[DataService] Error updating daily summary: $e');
    }
  }

  /// Obtiene el historial de resumenes diarios
  Future<List<Map<String, dynamic>>> getDailySummaries({
    required String visitorId,
    int days = 30,
  }) async {
    try {
      final profile = await getProfile(visitorId);
      if (profile == null) return [];

      final startDate = DateTime.now().subtract(Duration(days: days));

      final response = await _client
          .from(SupabaseConfig.dailySummariesTable)
          .select()
          .eq('user_id', profile['id'])
          .gte('summary_date', startDate.toIso8601String().split('T')[0])
          .order('summary_date', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('[DataService] Error getting daily summaries: $e');
      return [];
    }
  }

  /// Obtiene estadisticas de completados por rango de fechas
  Future<Map<String, dynamic>> getCompletionStats({
    required String visitorId,
    int days = 7,
  }) async {
    try {
      final profile = await getProfile(visitorId);
      if (profile == null) return {};

      final startDate = DateTime.now().subtract(Duration(days: days));

      final completions = await _client
          .from(SupabaseConfig.taskCompletionsTable)
          .select('completion_date, status')
          .eq('completed_by', profile['id'])
          .gte('completion_date', startDate.toIso8601String().split('T')[0])
          .eq('status', 'completed');

      // Agrupar por fecha
      final Map<String, int> byDate = {};
      for (final c in completions) {
        final date = c['completion_date'] as String;
        byDate[date] = (byDate[date] ?? 0) + 1;
      }

      // Calcular racha actual
      int streak = 0;
      var checkDate = DateTime.now();
      while (true) {
        final dateStr = checkDate.toIso8601String().split('T')[0];
        if (byDate.containsKey(dateStr)) {
          streak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else {
          // Si es hoy y no hay completados, no rompe la racha aun
          if (checkDate.day == DateTime.now().day) {
            checkDate = checkDate.subtract(const Duration(days: 1));
            continue;
          }
          break;
        }
      }

      return {
        'completions_by_date': byDate,
        'total_completions': completions.length,
        'current_streak': streak,
        'days_tracked': days,
      };
    } catch (e) {
      debugPrint('[DataService] Error getting completion stats: $e');
      return {};
    }
  }

  /// Obtiene el historial completo de completados
  Future<List<Map<String, dynamic>>> getCompletionHistory({
    required String visitorId,
    int days = 30,
  }) async {
    try {
      final profile = await getProfile(visitorId);
      if (profile == null) return [];

      final startDate = DateTime.now().subtract(Duration(days: days));

      final response = await _client
          .from(SupabaseConfig.taskCompletionsTable)
          .select('*, task:taskly_tasks(title, task_type, color)')
          .eq('completed_by', profile['id'])
          .gte('completion_date', startDate.toIso8601String().split('T')[0])
          .order('completion_date', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('[DataService] Error getting completion history: $e');
      return [];
    }
  }

  // ============================================================================
  // CHALLENGES
  // ============================================================================

  /// Crea un nuevo challenge
  Future<Map<String, dynamic>?> createChallenge({
    required String visitorId,
    required String title,
    String? description,
    String emoji = '🏆',
    required String challengeType,
    required int targetValue,
    String? categoryFilter,
    required DateTime startDate,
    required DateTime endDate,
    String visibility = 'household',
    String? householdId,
    int maxParticipants = 50,
  }) async {
    try {
      final profile = await getProfile(visitorId);
      if (profile == null) return null;

      final challengeId = _uuid.v4();

      final data = {
        'id': challengeId,
        'title': title,
        'description': description,
        'emoji': emoji,
        'challenge_type': challengeType,
        'target_value': targetValue,
        'category_filter': categoryFilter,
        'start_date': startDate.toIso8601String().split('T')[0],
        'end_date': endDate.toIso8601String().split('T')[0],
        'visibility': visibility,
        'household_id': householdId,
        'max_participants': maxParticipants,
        'created_by': profile['id'],
      };

      final response = await _client
          .from('taskly_challenges')
          .insert(data)
          .select()
          .single();

      // Auto-unirse al challenge creado
      await joinChallenge(visitorId: visitorId, challengeId: challengeId);

      debugPrint('[DataService] Challenge created: $challengeId');
      return response;
    } catch (e) {
      debugPrint('[DataService] Error creating challenge: $e');
      return null;
    }
  }

  /// Unirse a un challenge
  Future<Map<String, dynamic>?> joinChallenge({
    required String visitorId,
    required String challengeId,
  }) async {
    try {
      final profile = await getProfile(visitorId);
      if (profile == null) return null;

      final data = {
        'id': _uuid.v4(),
        'challenge_id': challengeId,
        'user_id': profile['id'],
        'current_score': 0,
        'best_streak': 0,
      };

      final response = await _client
          .from('taskly_challenge_participants')
          .upsert(data, onConflict: 'challenge_id,user_id')
          .select()
          .single();

      debugPrint('[DataService] Joined challenge: $challengeId');
      return response;
    } catch (e) {
      debugPrint('[DataService] Error joining challenge: $e');
      return null;
    }
  }

  /// Unirse a un challenge por código de invitación
  Future<Map<String, dynamic>?> joinChallengeByCode({
    required String visitorId,
    required String inviteCode,
  }) async {
    try {
      // Buscar challenge por código
      final challenge = await _client
          .from('taskly_challenges')
          .select()
          .eq('invite_code', inviteCode)
          .maybeSingle();

      if (challenge == null) {
        debugPrint('[DataService] Challenge not found with code: $inviteCode');
        return null;
      }

      return joinChallenge(visitorId: visitorId, challengeId: challenge['id']);
    } catch (e) {
      debugPrint('[DataService] Error joining challenge by code: $e');
      return null;
    }
  }

  /// Obtiene los challenges disponibles para el usuario
  Future<List<Map<String, dynamic>>> getChallenges({
    required String visitorId,
    bool activeOnly = false,
  }) async {
    try {
      final profile = await getProfile(visitorId);
      if (profile == null) return [];

      // Obtener households del usuario para filtrar challenges de household
      final householdIds = <String>[];
      final memberships = await _client
          .from(SupabaseConfig.householdMembersTable)
          .select('household_id')
          .eq('user_id', profile['id']);

      for (final m in memberships) {
        householdIds.add(m['household_id'] as String);
      }

      var query = _client.from('taskly_challenges').select('''
        *,
        participants:taskly_challenge_participants(count),
        my_participation:taskly_challenge_participants!inner(id, current_score, best_streak, joined_at)
      ''').eq('my_participation.user_id', profile['id']);

      if (activeOnly) {
        query = query.eq('status', 'active');
      }

      final response = await query.order('start_date', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('[DataService] Error getting challenges: $e');
      return [];
    }
  }

  /// Obtiene challenges públicos o disponibles
  Future<List<Map<String, dynamic>>> getAvailableChallenges({
    required String visitorId,
  }) async {
    try {
      final profile = await getProfile(visitorId);
      if (profile == null) return [];

      // Obtener households del usuario
      final householdIds = <String>[];
      final memberships = await _client
          .from(SupabaseConfig.householdMembersTable)
          .select('household_id')
          .eq('user_id', profile['id']);

      for (final m in memberships) {
        householdIds.add(m['household_id'] as String);
      }

      // Challenges públicos o de mis households, que aún no he unido
      final response = await _client
          .from('taskly_challenges')
          .select('''
            *,
            participants:taskly_challenge_participants(count),
            creator:taskly_profiles!created_by(display_name, avatar_url)
          ''')
          .or('visibility.eq.public,household_id.in.(${householdIds.join(",")})')
          .neq('status', 'cancelled')
          .order('start_date', ascending: true);

      // Filtrar los que ya tengo
      final myChallenges = await getChallenges(visitorId: visitorId);
      final myIds = myChallenges.map((c) => c['id']).toSet();

      return List<Map<String, dynamic>>.from(response)
          .where((c) => !myIds.contains(c['id']))
          .toList();
    } catch (e) {
      debugPrint('[DataService] Error getting available challenges: $e');
      return [];
    }
  }

  /// Obtiene el leaderboard de un challenge
  Future<List<Map<String, dynamic>>> getChallengeLeaderboard(
    String challengeId,
  ) async {
    try {
      final response = await _client
          .from('taskly_leaderboard')
          .select()
          .eq('challenge_id', challengeId)
          .order('rank', ascending: true)
          .limit(50);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('[DataService] Error getting leaderboard: $e');
      return [];
    }
  }

  /// Actualiza el puntaje de un participante
  Future<void> updateChallengeScore({
    required String visitorId,
    required String challengeId,
    required int scoreIncrement,
  }) async {
    try {
      final profile = await getProfile(visitorId);
      if (profile == null) return;

      // Obtener participación actual
      final participation = await _client
          .from('taskly_challenge_participants')
          .select()
          .eq('challenge_id', challengeId)
          .eq('user_id', profile['id'])
          .maybeSingle();

      if (participation == null) return;

      final newScore = (participation['current_score'] as int? ?? 0) + scoreIncrement;

      await _client
          .from('taskly_challenge_participants')
          .update({
            'current_score': newScore,
            'last_activity_date': DateTime.now().toIso8601String().split('T')[0],
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', participation['id']);

      debugPrint('[DataService] Challenge score updated: +$scoreIncrement');
    } catch (e) {
      debugPrint('[DataService] Error updating challenge score: $e');
    }
  }

  /// Obtiene estadísticas del usuario en challenges
  Future<Map<String, dynamic>> getChallengeStats(String visitorId) async {
    try {
      final profile = await getProfile(visitorId);
      if (profile == null) return {};

      final stats = await _client
          .from('taskly_user_challenge_stats')
          .select()
          .eq('user_id', profile['id'])
          .maybeSingle();

      return stats ?? {
        'active_challenges': 0,
        'challenges_won': 0,
        'total_points': 0,
        'all_time_best_streak': 0,
        'average_rank': 0,
      };
    } catch (e) {
      debugPrint('[DataService] Error getting challenge stats: $e');
      return {};
    }
  }

  /// Abandona un challenge
  Future<bool> leaveChallenge({
    required String visitorId,
    required String challengeId,
  }) async {
    try {
      final profile = await getProfile(visitorId);
      if (profile == null) return false;

      await _client
          .from('taskly_challenge_participants')
          .update({'is_active': false})
          .eq('challenge_id', challengeId)
          .eq('user_id', profile['id']);

      debugPrint('[DataService] Left challenge: $challengeId');
      return true;
    } catch (e) {
      debugPrint('[DataService] Error leaving challenge: $e');
      return false;
    }
  }
}
