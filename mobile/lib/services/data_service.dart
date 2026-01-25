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

  /// Actualiza el token FCM del usuario para notificaciones push
  Future<void> updateProfileFcmToken({
    required String firebaseUid,
    required String fcmToken,
  }) async {
    try {
      await _client
          .from(SupabaseConfig.profilesTable)
          .update({
            'fcm_token': fcmToken,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('firebase_uid', firebaseUid);
      debugPrint('[DataService] FCM token updated for user: $firebaseUid');
    } catch (e) {
      debugPrint('[DataService] Error updating FCM token: $e');
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
    String? householdId,
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
        if (householdId != null) 'household_id': householdId,
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
          .select()
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

  /// Actualiza una categoría personalizada
  Future<Map<String, dynamic>?> updateCategory({
    required String categoryId,
    String? name,
    String? icon,
    String? color,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (name != null) updates['name'] = name;
      if (icon != null) updates['icon'] = icon;
      if (color != null) updates['color'] = color;

      if (updates.isEmpty) return null;

      final response = await _client
          .from(SupabaseConfig.categoriesTable)
          .update(updates)
          .eq('id', categoryId)
          .select()
          .single();

      debugPrint('[DataService] Category updated: $categoryId');
      return response;
    } catch (e) {
      debugPrint('[DataService] Error updating category: $e');
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

      // Obtener membresías del usuario
      final memberships = await _client
          .from(SupabaseConfig.householdMembersTable)
          .select('household_id, role')
          .eq('user_id', profile['id']);

      if (memberships.isEmpty) return [];

      // Obtener los hogares correspondientes
      final householdIds = memberships.map((m) => m['household_id'] as String).toList();
      final households = await _client
          .from(SupabaseConfig.householdsTable)
          .select()
          .inFilter('id', householdIds);

      // Combinar datos
      final result = <Map<String, dynamic>>[];
      for (final membership in memberships) {
        final household = households.firstWhere(
          (h) => h['id'] == membership['household_id'],
          orElse: () => <String, dynamic>{},
        );
        if (household.isNotEmpty) {
          result.add({
            'household_id': membership['household_id'],
            'role': membership['role'],
            'household': household,
          });
        }
      }

      return result;
    } catch (e) {
      debugPrint('[DataService] Error getting households: $e');
      return [];
    }
  }

  /// Actualiza un hogar (nombre, icono, color, imagen)
  Future<Map<String, dynamic>?> updateHousehold({
    required String householdId,
    String? name,
    String? icon,
    String? color,
    String? imageUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (icon != null) updates['icon'] = icon;
      if (color != null) updates['color'] = color;
      if (imageUrl != null) updates['image_url'] = imageUrl;

      if (updates.isEmpty) return null;

      final result = await _client
          .from(SupabaseConfig.householdsTable)
          .update(updates)
          .eq('id', householdId)
          .select()
          .single();

      debugPrint('[DataService] Updated household: $householdId');
      return result;
    } catch (e) {
      debugPrint('[DataService] Error updating household: $e');
      return null;
    }
  }

  /// Obtiene las tareas de un grupo/hogar
  Future<List<Map<String, dynamic>>> getGroupTasks({
    required String householdId,
  }) async {
    try {
      final tasks = await _client
          .from(SupabaseConfig.tasksTable)
          .select()
          .eq('household_id', householdId)
          .order('created_at', ascending: false);

      return tasks;
    } catch (e) {
      debugPrint('[DataService] Error getting group tasks: $e');
      return [];
    }
  }

  /// Obtiene los miembros de un hogar
  Future<List<Map<String, dynamic>>> getHouseholdMembers({
    required String householdId,
  }) async {
    try {
      final memberships = await _client
          .from(SupabaseConfig.householdMembersTable)
          .select('user_id, role, joined_at')
          .eq('household_id', householdId);

      if (memberships.isEmpty) return [];

      // Obtener los perfiles de los usuarios
      final userIds = memberships.map((m) => m['user_id'] as String).toList();
      final profiles = await _client
          .from(SupabaseConfig.profilesTable)
          .select('id, display_name, photo_url')
          .inFilter('id', userIds);

      // Combinar datos
      final result = <Map<String, dynamic>>[];
      for (final membership in memberships) {
        final profile = profiles.firstWhere(
          (p) => p['id'] == membership['user_id'],
          orElse: () => <String, dynamic>{},
        );
        if (profile.isNotEmpty) {
          result.add({
            ...profile,
            'role': membership['role'],
            'joined_at': membership['joined_at'],
          });
        }
      }

      return result;
    } catch (e) {
      debugPrint('[DataService] Error getting household members: $e');
      return [];
    }
  }

  /// Elimina un hogar/grupo y todos sus datos asociados
  Future<bool> deleteHousehold(String householdId) async {
    try {
      // Eliminar miembros primero (por integridad referencial)
      await _client
          .from(SupabaseConfig.householdMembersTable)
          .delete()
          .eq('household_id', householdId);

      // Eliminar tareas del grupo
      await _client
          .from(SupabaseConfig.tasksTable)
          .delete()
          .eq('household_id', householdId);

      // Eliminar el hogar
      await _client
          .from(SupabaseConfig.householdsTable)
          .delete()
          .eq('id', householdId);

      debugPrint('[DataService] Deleted household: $householdId');
      return true;
    } catch (e) {
      debugPrint('[DataService] Error deleting household: $e');
      return false;
    }
  }

  /// Actualiza el rol de un miembro del hogar
  Future<bool> updateMemberRole({
    required String householdId,
    required String userId,
    required String newRole,
  }) async {
    try {
      await _client
          .from(SupabaseConfig.householdMembersTable)
          .update({'role': newRole})
          .eq('household_id', householdId)
          .eq('user_id', userId);

      debugPrint('[DataService] Updated role for user $userId to $newRole');
      return true;
    } catch (e) {
      debugPrint('[DataService] Error updating member role: $e');
      return false;
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

      // Obtener completados
      final completions = await _client
          .from(SupabaseConfig.taskCompletionsTable)
          .select()
          .eq('completed_by', profile['id'])
          .gte('completion_date', startDate.toIso8601String().split('T')[0])
          .order('completion_date', ascending: false);

      if (completions.isEmpty) return [];

      // Obtener las tareas correspondientes
      final taskIds = completions.map((c) => c['task_id'] as String).toSet().toList();
      final tasks = await _client
          .from(SupabaseConfig.tasksTable)
          .select('id, title, task_type, color')
          .inFilter('id', taskIds);

      // Crear mapa de tareas para lookup rápido
      final taskMap = <String, Map<String, dynamic>>{};
      for (final task in tasks) {
        taskMap[task['id'] as String] = task;
      }

      // Combinar datos
      return completions.map((c) {
        final task = taskMap[c['task_id']] ?? {};
        return {
          ...c,
          'task': task,
        };
      }).toList();
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

  /// Obtiene los challenges donde participa el usuario
  Future<List<Map<String, dynamic>>> getChallenges({
    required String visitorId,
    bool activeOnly = false,
  }) async {
    try {
      final profile = await getProfile(visitorId);
      if (profile == null) return [];

      // Obtener participaciones del usuario
      final participations = await _client
          .from('taskly_challenge_participants')
          .select('challenge_id, current_score, best_streak, joined_at')
          .eq('user_id', profile['id'])
          .eq('is_active', true);

      if (participations.isEmpty) return [];

      // Obtener los challenges correspondientes
      final challengeIds = participations.map((p) => p['challenge_id'] as String).toList();

      var query = _client
          .from('taskly_challenges')
          .select()
          .inFilter('id', challengeIds);

      if (activeOnly) {
        query = query.eq('status', 'active');
      }

      final challenges = await query.order('start_date', ascending: false);

      // Combinar con participación
      final result = <Map<String, dynamic>>[];
      for (final challenge in challenges) {
        final participation = participations.firstWhere(
          (p) => p['challenge_id'] == challenge['id'],
          orElse: () => <String, dynamic>{},
        );
        result.add({
          ...challenge,
          'my_participation': participation,
        });
      }

      return result;
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

      // Obtener challenges donde ya participa
      final myParticipations = await _client
          .from('taskly_challenge_participants')
          .select('challenge_id')
          .eq('user_id', profile['id']);

      final myIds = myParticipations.map((p) => p['challenge_id'] as String).toSet();

      // Obtener households del usuario
      final memberships = await _client
          .from(SupabaseConfig.householdMembersTable)
          .select('household_id')
          .eq('user_id', profile['id']);

      final householdIds = memberships.map((m) => m['household_id'] as String).toList();

      // Obtener challenges públicos
      final publicChallenges = await _client
          .from('taskly_challenges')
          .select()
          .eq('visibility', 'public')
          .neq('status', 'cancelled')
          .order('start_date', ascending: true);

      // Obtener challenges de mis households (si tengo)
      List<dynamic> householdChallenges = [];
      if (householdIds.isNotEmpty) {
        householdChallenges = await _client
            .from('taskly_challenges')
            .select()
            .eq('visibility', 'household')
            .inFilter('household_id', householdIds)
            .neq('status', 'cancelled')
            .order('start_date', ascending: true);
      }

      // Combinar y filtrar los que ya tengo
      final allChallenges = <Map<String, dynamic>>[
        ...List<Map<String, dynamic>>.from(publicChallenges),
        ...List<Map<String, dynamic>>.from(householdChallenges),
      ];

      // Eliminar duplicados y los que ya tengo
      final seen = <String>{};
      return allChallenges
          .where((c) {
            final id = c['id'] as String;
            if (seen.contains(id) || myIds.contains(id)) return false;
            seen.add(id);
            return true;
          })
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
