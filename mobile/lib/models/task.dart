/// Recurrence type for tasks
enum TaskRecurrence {
  none, // One-time task
  daily,
  weekly,
  monthly,
}

/// Priority level for tasks
enum TaskPriority {
  low,
  medium,
  high,
}

/// Represents a task that can be one-time or recurring.
/// Can be personal or shared (for household tasks).
class Task {
  final String id;
  final String title;
  final String? description;
  final TaskRecurrence recurrence;
  final TaskPriority priority;
  final DateTime? dueDate; // For one-time tasks
  final int? dayOfWeek; // 1-7 for weekly tasks (Monday = 1)
  final int? dayOfMonth; // 1-31 for monthly tasks
  final bool isCompleted; // For one-time tasks
  final bool isShared; // Whether this is a shared household task
  final String? householdId; // ID of the household for shared tasks
  final String? assignedTo; // User ID of assigned person (for shared tasks)
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? userId; // Creator's user ID, null for local-only

  const Task({
    required this.id,
    required this.title,
    this.description,
    this.recurrence = TaskRecurrence.none,
    this.priority = TaskPriority.medium,
    this.dueDate,
    this.dayOfWeek,
    this.dayOfMonth,
    this.isCompleted = false,
    this.isShared = false,
    this.householdId,
    this.assignedTo,
    required this.createdAt,
    this.updatedAt,
    this.userId,
  });

  bool get isRecurring => recurrence != TaskRecurrence.none;
  bool get isOneTime => recurrence == TaskRecurrence.none;

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskRecurrence? recurrence,
    TaskPriority? priority,
    DateTime? dueDate,
    int? dayOfWeek,
    int? dayOfMonth,
    bool? isCompleted,
    bool? isShared,
    String? householdId,
    String? assignedTo,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      recurrence: recurrence ?? this.recurrence,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      isCompleted: isCompleted ?? this.isCompleted,
      isShared: isShared ?? this.isShared,
      householdId: householdId ?? this.householdId,
      assignedTo: assignedTo ?? this.assignedTo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'recurrence': recurrence.name,
      'priority': priority.name,
      'due_date': dueDate?.toIso8601String(),
      'day_of_week': dayOfWeek,
      'day_of_month': dayOfMonth,
      'is_completed': isCompleted,
      'is_shared': isShared,
      'household_id': householdId,
      'assigned_to': assignedTo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'user_id': userId,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      recurrence: TaskRecurrence.values.firstWhere(
        (e) => e.name == json['recurrence'],
        orElse: () => TaskRecurrence.none,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      dayOfWeek: json['day_of_week'] as int?,
      dayOfMonth: json['day_of_month'] as int?,
      isCompleted: json['is_completed'] as bool? ?? false,
      isShared: json['is_shared'] as bool? ?? false,
      householdId: json['household_id'] as String?,
      assignedTo: json['assigned_to'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      userId: json['user_id'] as String?,
    );
  }
}
