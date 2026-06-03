enum TransactionType {
  gameComplete,
  dailyBonus,
  streakBonus,
  achievement,
  spend,
}

class PointTransaction {
  final String id;
  final TransactionType type;
  final int delta;
  final String description;
  final DateTime createdAt;

  const PointTransaction({
    required this.id,
    required this.type,
    required this.delta,
    required this.description,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'delta': delta,
        'description': description,
        'created_at': createdAt.toIso8601String(),
      };

  factory PointTransaction.fromJson(Map<String, dynamic> json) =>
      PointTransaction(
        id: json['id'] as String,
        type: TransactionType.values.byName(json['type'] as String),
        delta: (json['delta'] as num).toInt(),
        description: json['description'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
