/// Represents a daily goal that the user wants to track consistently.
/// Examples: "Drink 8 glasses of water", "Exercise 30 minutes", "Read 20 pages"
class Goal {
  final String id;
  final String title;
  final String? description;
  final String? icon; // Icon identifier or emoji
  final int targetValue; // Target to reach (e.g., 8 glasses, 30 minutes)
  final String unit; // Unit of measurement (e.g., "glasses", "minutes", "pages")
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? userId; // null for local-only goals

  const Goal({
    required this.id,
    required this.title,
    this.description,
    this.icon,
    this.targetValue = 1,
    this.unit = 'times',
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.userId,
  });

  Goal copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    int? targetValue,
    String? unit,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      targetValue: targetValue ?? this.targetValue,
      unit: unit ?? this.unit,
      isActive: isActive ?? this.isActive,
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
      'icon': icon,
      'target_value': targetValue,
      'unit': unit,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'user_id': userId,
    };
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      targetValue: json['target_value'] as int? ?? 1,
      unit: json['unit'] as String? ?? 'times',
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      userId: json['user_id'] as String?,
    );
  }
}
