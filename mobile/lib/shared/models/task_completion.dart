import 'package:equatable/equatable.dart';

/// Represents a completion record for a goal or task on a specific date.
/// Used to track daily progress for goals and completion of recurring tasks.
class TaskCompletion extends Equatable {
  final String id;
  final String? goalId; // Reference to Goal (for goal completions)
  final String? taskId; // Reference to Task (for task completions)
  final DateTime date; // The date this completion is for
  final int value; // Current progress value (e.g., 5 glasses of water)
  final bool isCompleted; // Whether the target was met
  final String? notes; // Optional notes for this day
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? userId; // null for local-only

  const TaskCompletion({
    required this.id,
    this.goalId,
    this.taskId,
    required this.date,
    this.value = 0,
    this.isCompleted = false,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.userId,
  });

  /// Whether this is a goal completion
  bool get isGoalCompletion => goalId != null;

  /// Whether this is a task completion
  bool get isTaskCompletion => taskId != null;

  TaskCompletion copyWith({
    String? id,
    String? goalId,
    String? taskId,
    DateTime? date,
    int? value,
    bool? isCompleted,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
  }) {
    return TaskCompletion(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      taskId: taskId ?? this.taskId,
      date: date ?? this.date,
      value: value ?? this.value,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goal_id': goalId,
      'task_id': taskId,
      'date': date.toIso8601String().split('T').first, // Store date only
      'value': value,
      'is_completed': isCompleted,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'user_id': userId,
    };
  }

  factory TaskCompletion.fromJson(Map<String, dynamic> json) {
    return TaskCompletion(
      id: json['id'] as String,
      goalId: json['goal_id'] as String?,
      taskId: json['task_id'] as String?,
      date: DateTime.parse(json['date'] as String),
      value: json['value'] as int? ?? 0,
      isCompleted: json['is_completed'] as bool? ?? false,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      userId: json['user_id'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        goalId,
        taskId,
        date,
        value,
        isCompleted,
        notes,
        createdAt,
        updatedAt,
        userId,
      ];
}
