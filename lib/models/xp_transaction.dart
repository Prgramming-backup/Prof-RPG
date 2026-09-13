class XpTransaction {
  const XpTransaction({
    required this.id,
    required this.sourceTaskId,
    required this.completionId,
    required this.baseXp,
    required this.awardedXp,
    required this.timestamp,
    this.multiplier = 1.0,
    this.reversed = false,
  });

  final String id;
  final String sourceTaskId;
  final String completionId;
  final int baseXp;
  final double multiplier;
  final int awardedXp;
  final DateTime timestamp;
  final bool reversed;

  String get taskId => sourceTaskId;
  int get finalXp => awardedXp;

  XpTransaction reversedCopy() => XpTransaction(
    id: id,
    sourceTaskId: sourceTaskId,
    completionId: completionId,
    baseXp: baseXp,
    multiplier: multiplier,
    awardedXp: awardedXp,
    timestamp: timestamp,
    reversed: true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'sourceTaskId': sourceTaskId,
    'completionId': completionId,
    'baseXp': baseXp,
    'multiplier': multiplier,
    'awardedXp': awardedXp,
    'timestamp': timestamp.toIso8601String(),
    'reversed': reversed,
  };

  factory XpTransaction.fromJson(Map<String, dynamic> json) {
    return XpTransaction(
      id: json['id'] as String,
      sourceTaskId: json['sourceTaskId'] as String,
      completionId: json['completionId'] as String,
      baseXp: (json['baseXp'] as num).toInt(),
      multiplier: (json['multiplier'] as num?)?.toDouble() ?? 1.0,
      awardedXp: (json['awardedXp'] as num).toInt(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      reversed: json['reversed'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is XpTransaction &&
          id == other.id &&
          sourceTaskId == other.sourceTaskId &&
          completionId == other.completionId &&
          baseXp == other.baseXp &&
          multiplier == other.multiplier &&
          awardedXp == other.awardedXp &&
          timestamp == other.timestamp &&
          reversed == other.reversed;

  @override
  int get hashCode => Object.hash(
        id,
        sourceTaskId,
        completionId,
        baseXp,
        multiplier,
        awardedXp,
        timestamp,
        reversed,
      );
}
