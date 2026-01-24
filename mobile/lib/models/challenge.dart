import 'package:flutter/material.dart';

enum ChallengeType {
  streak,      // Mantener racha
  completion,  // Completar X tareas
  category,    // Tareas de categoría
  speed,       // Antes de cierta hora
  perfectDay,  // Días 100% completados
}

enum ChallengeStatus {
  upcoming,
  active,
  completed,
  cancelled,
}

enum ChallengeVisibility {
  public,
  household,
  inviteOnly,
}

class Challenge {
  final String id;
  final String title;
  final String? description;
  final String emoji;
  final ChallengeType type;
  final int targetValue;
  final String? categoryFilter;
  final DateTime startDate;
  final DateTime endDate;
  final ChallengeVisibility visibility;
  final String? householdId;
  final String? inviteCode;
  final int maxParticipants;
  final ChallengeStatus status;
  final String createdBy;
  final DateTime createdAt;

  Challenge({
    required this.id,
    required this.title,
    this.description,
    required this.emoji,
    required this.type,
    required this.targetValue,
    this.categoryFilter,
    required this.startDate,
    required this.endDate,
    required this.visibility,
    this.householdId,
    this.inviteCode,
    this.maxParticipants = 50,
    required this.status,
    required this.createdBy,
    required this.createdAt,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      emoji: json['emoji'] as String? ?? '🏆',
      type: _parseType(json['challenge_type'] as String?),
      targetValue: json['target_value'] as int? ?? 1,
      categoryFilter: json['category_filter'] as String?,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      visibility: _parseVisibility(json['visibility'] as String?),
      householdId: json['household_id'] as String?,
      inviteCode: json['invite_code'] as String?,
      maxParticipants: json['max_participants'] as int? ?? 50,
      status: _parseStatus(json['status'] as String?),
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'emoji': emoji,
      'challenge_type': type.name,
      'target_value': targetValue,
      'category_filter': categoryFilter,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'visibility': visibility.name == 'inviteOnly' ? 'invite_only' : visibility.name,
      'household_id': householdId,
      'max_participants': maxParticipants,
    };
  }

  static ChallengeType _parseType(String? value) {
    switch (value) {
      case 'streak':
        return ChallengeType.streak;
      case 'completion':
        return ChallengeType.completion;
      case 'category':
        return ChallengeType.category;
      case 'speed':
        return ChallengeType.speed;
      case 'perfect_day':
        return ChallengeType.perfectDay;
      default:
        return ChallengeType.completion;
    }
  }

  static ChallengeStatus _parseStatus(String? value) {
    switch (value) {
      case 'upcoming':
        return ChallengeStatus.upcoming;
      case 'active':
        return ChallengeStatus.active;
      case 'completed':
        return ChallengeStatus.completed;
      case 'cancelled':
        return ChallengeStatus.cancelled;
      default:
        return ChallengeStatus.upcoming;
    }
  }

  static ChallengeVisibility _parseVisibility(String? value) {
    switch (value) {
      case 'public':
        return ChallengeVisibility.public;
      case 'household':
        return ChallengeVisibility.household;
      case 'invite_only':
        return ChallengeVisibility.inviteOnly;
      default:
        return ChallengeVisibility.household;
    }
  }

  String get typeLabel {
    switch (type) {
      case ChallengeType.streak:
        return 'Racha';
      case ChallengeType.completion:
        return 'Completar';
      case ChallengeType.category:
        return 'Categoría';
      case ChallengeType.speed:
        return 'Velocidad';
      case ChallengeType.perfectDay:
        return 'Día perfecto';
    }
  }

  String get typeDescription {
    switch (type) {
      case ChallengeType.streak:
        return 'Mantén una racha de $targetValue días';
      case ChallengeType.completion:
        return 'Completa $targetValue tareas';
      case ChallengeType.category:
        return 'Completa $targetValue tareas de $categoryFilter';
      case ChallengeType.speed:
        return 'Completa tareas antes de las $targetValue:00';
      case ChallengeType.perfectDay:
        return 'Logra $targetValue días perfectos';
    }
  }

  IconData get typeIcon {
    switch (type) {
      case ChallengeType.streak:
        return Icons.local_fire_department;
      case ChallengeType.completion:
        return Icons.check_circle;
      case ChallengeType.category:
        return Icons.category;
      case ChallengeType.speed:
        return Icons.speed;
      case ChallengeType.perfectDay:
        return Icons.star;
    }
  }

  bool get isActive => status == ChallengeStatus.active;
  bool get isUpcoming => status == ChallengeStatus.upcoming;
  bool get isCompleted => status == ChallengeStatus.completed;

  int get daysRemaining {
    final now = DateTime.now();
    return endDate.difference(now).inDays;
  }

  double get progress {
    final total = endDate.difference(startDate).inDays;
    final elapsed = DateTime.now().difference(startDate).inDays;
    if (total <= 0) return 1.0;
    return (elapsed / total).clamp(0.0, 1.0);
  }
}

class ChallengeParticipant {
  final String id;
  final String challengeId;
  final String visitorId;
  final String? displayName;
  final String? avatarUrl;
  final int currentScore;
  final int bestStreak;
  final DateTime? lastActivityDate;
  final DateTime joinedAt;
  final int rank;
  final bool goalReached;

  ChallengeParticipant({
    required this.id,
    required this.challengeId,
    required this.visitorId,
    this.displayName,
    this.avatarUrl,
    required this.currentScore,
    required this.bestStreak,
    this.lastActivityDate,
    required this.joinedAt,
    required this.rank,
    required this.goalReached,
  });

  factory ChallengeParticipant.fromJson(Map<String, dynamic> json) {
    return ChallengeParticipant(
      id: json['id'] as String? ?? json['user_id'] as String,
      challengeId: json['challenge_id'] as String,
      visitorId: json['user_id'] as String,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      currentScore: json['current_score'] as int? ?? 0,
      bestStreak: json['best_streak'] as int? ?? 0,
      lastActivityDate: json['last_activity_date'] != null
          ? DateTime.parse(json['last_activity_date'] as String)
          : null,
      joinedAt: DateTime.parse(json['joined_at'] as String),
      rank: json['rank'] as int? ?? 0,
      goalReached: json['goal_reached'] as bool? ?? false,
    );
  }

  String get displayInitials {
    if (displayName == null || displayName!.isEmpty) return '?';
    final parts = displayName!.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return displayName![0].toUpperCase();
  }
}
