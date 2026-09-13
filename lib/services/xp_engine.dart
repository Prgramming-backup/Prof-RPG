enum XpAwardStatus { awarded, duplicate, invalidXp }

class XpDecision {
  const XpDecision({
    required this.status,
    required this.baseXp,
    required this.awardedXp,
    this.multiplier = 1.0,
  });

  const XpDecision.awarded({
    required int baseXp,
    int? awardedXp,
    double multiplier = 1.0,
  }) : this(
         status: XpAwardStatus.awarded,
         baseXp: baseXp,
         awardedXp: awardedXp ?? baseXp,
         multiplier: multiplier,
       );

  const XpDecision.duplicate({required int baseXp})
    : this(status: XpAwardStatus.duplicate, baseXp: baseXp, awardedXp: 0);

  const XpDecision.invalidXp({required int baseXp})
    : this(status: XpAwardStatus.invalidXp, baseXp: baseXp, awardedXp: 0);

  final XpAwardStatus status;
  final int baseXp;
  final int awardedXp;
  final double multiplier;

  int get finalXp => awardedXp;
  bool get isAwarded => status == XpAwardStatus.awarded;

  @override
  bool operator ==(Object other) {
    return other is XpDecision &&
        other.status == status &&
        other.baseXp == baseXp &&
        other.awardedXp == awardedXp &&
        other.multiplier == multiplier;
  }

  @override
  int get hashCode => Object.hash(status, baseXp, awardedXp, multiplier);
}

/// Pure XP calculator. Callers supply all inputs; the engine does not
/// read or write UI or repository state.
class XpEngine {
  const XpEngine();

  XpDecision decide({
    required int baseXp,
    required bool alreadyAwardedForCompletion,
    double multiplier = 1.0,
  }) {
    if (baseXp <= 0) {
      return XpDecision.invalidXp(baseXp: baseXp);
    }
    if (alreadyAwardedForCompletion) {
      return XpDecision.duplicate(baseXp: baseXp);
    }
    final finalXp = (baseXp * multiplier).round();
    return XpDecision.awarded(
      baseXp: baseXp,
      awardedXp: finalXp,
      multiplier: multiplier,
    );
  }
}
