class UserProfile {
  final String id;
  final String displayName;
  final String email;
  final String? avatarUrl;
  final int totalPoints;
  final int gamesPlayed;
  final int streakDays;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.displayName,
    required this.email,
    this.avatarUrl,
    this.totalPoints = 0,
    this.gamesPlayed = 0,
    this.streakDays = 1,
    required this.createdAt,
  });

  UserProfile copyWith({
    int? totalPoints,
    int? gamesPlayed,
    int? streakDays,
    String? displayName,
    String? avatarUrl,
  }) {
    return UserProfile(
      id: id,
      displayName: displayName ?? this.displayName,
      email: email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      totalPoints: totalPoints ?? this.totalPoints,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      streakDays: streakDays ?? this.streakDays,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'display_name': displayName,
        'email': email,
        'avatar_url': avatarUrl,
        'total_points': totalPoints,
        'games_played': gamesPlayed,
        'streak_days': streakDays,
        'created_at': createdAt.toIso8601String(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        displayName: json['display_name'] as String,
        email: json['email'] as String,
        avatarUrl: json['avatar_url'] as String?,
        totalPoints: (json['total_points'] as num?)?.toInt() ?? 0,
        gamesPlayed: (json['games_played'] as num?)?.toInt() ?? 0,
        streakDays: (json['streak_days'] as num?)?.toInt() ?? 1,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
