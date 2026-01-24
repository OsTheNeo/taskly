/// Represents a user profile in the app.
/// When logged in, syncs with Supabase. Otherwise, local-only.
class UserProfile {
  final String id;
  final String? email;
  final String? displayName;
  final String? avatarUrl;
  final String? householdId; // ID of the household they belong to
  final bool isLoggedIn;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastSyncAt; // Last time data was synced with server

  const UserProfile({
    required this.id,
    this.email,
    this.displayName,
    this.avatarUrl,
    this.householdId,
    this.isLoggedIn = false,
    required this.createdAt,
    this.updatedAt,
    this.lastSyncAt,
  });

  /// Creates a local-only guest user
  factory UserProfile.guest() {
    return UserProfile(
      id: 'local_user',
      displayName: 'Guest',
      isLoggedIn: false,
      createdAt: DateTime.now(),
    );
  }

  bool get isGuest => !isLoggedIn;
  bool get hasHousehold => householdId != null;

  UserProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    String? avatarUrl,
    String? householdId,
    bool? isLoggedIn,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      householdId: householdId ?? this.householdId,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'household_id': householdId,
      'is_logged_in': isLoggedIn,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'last_sync_at': lastSyncAt?.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String?,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      householdId: json['household_id'] as String?,
      isLoggedIn: json['is_logged_in'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      lastSyncAt: json['last_sync_at'] != null
          ? DateTime.parse(json['last_sync_at'] as String)
          : null,
    );
  }
}
