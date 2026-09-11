class XpTransaction {
  const XpTransaction({
    required this.id,
    required this.sourceTaskId,
    required this.completionId,
    required this.baseXp,
    required this.awardedXp,
    required this.timestamp,
    this.reversed = false,
  });

  final String id;
  final String sourceTaskId;
  final String completionId;
  final int baseXp;
  final int awardedXp;
  final DateTime timestamp;
  final bool reversed;

  XpTransaction reversedCopy() => XpTransaction(
    id: id,
    sourceTaskId: sourceTaskId,
    completionId: completionId,
    baseXp: baseXp,
    awardedXp: awardedXp,
    timestamp: timestamp,
    reversed: true,
  );
}
