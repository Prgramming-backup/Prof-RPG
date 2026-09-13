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
}
