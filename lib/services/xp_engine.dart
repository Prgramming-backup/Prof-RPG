enum XpAwardStatus { awarded, duplicate, invalidXp }

class XpDecision {
  const XpDecision({
    required this.status,
    required this.baseXp,
    required this.awardedXp,
  });

  const XpDecision.awarded({required int baseXp})
    : this(status: XpAwardStatus.awarded, baseXp: baseXp, awardedXp: baseXp);

  const XpDecision.duplicate({required int baseXp})
    : this(status: XpAwardStatus.duplicate, baseXp: baseXp, awardedXp: 0);

  const XpDecision.invalidXp({required int baseXp})
    : this(status: XpAwardStatus.invalidXp, baseXp: baseXp, awardedXp: 0);

  final XpAwardStatus status;
  final int baseXp;
  final int awardedXp;

  bool get isAwarded => status == XpAwardStatus.awarded;

  @override
  bool operator ==(Object other) {
    return other is XpDecision &&
        other.status == status &&
        other.baseXp == baseXp &&
        other.awardedXp == awardedXp;
  }

  @override
  int get hashCode => Object.hash(status, baseXp, awardedXp);
}

/// Pure XP calculator. Callers supply all inputs; the engine does not
/// read or write UI or repository state.
class XpEngine {
  const XpEngine();

  XpDecision decide({
    required int baseXp,
    required bool alreadyAwardedForCompletion,
  }) {
    if (baseXp <= 0) {
      return XpDecision.invalidXp(baseXp: baseXp);
    }
    if (alreadyAwardedForCompletion) {
      return XpDecision.duplicate(baseXp: baseXp);
    }
    return XpDecision.awarded(baseXp: baseXp);
  }
}
