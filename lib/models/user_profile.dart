class UserProfile {
  final String id;
  final String email;
  final String? username;
  final String? avatarUrl;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.email,
    this.username,
    this.avatarUrl,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'avatar_url': avatarUrl,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? username,
    String? avatarUrl,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
