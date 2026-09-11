import 'package:flutter_test/flutter_test.dart';

import 'package:prod/services/xp_engine.dart';

void main() {
  const engine = XpEngine();

  test('awards base XP for a normal completion', () {
    final decision = engine.decide(
      baseXp: 20,
      alreadyAwardedForCompletion: false,
    );

    expect(decision, const XpDecision.awarded(baseXp: 20));
    expect(decision.awardedXp, 20);
  });

  test('rejects zero and negative XP', () {
    expect(
      engine.decide(baseXp: 0, alreadyAwardedForCompletion: false),
      const XpDecision.invalidXp(baseXp: 0),
    );
    expect(
      engine.decide(baseXp: -10, alreadyAwardedForCompletion: false),
      const XpDecision.invalidXp(baseXp: -10),
    );
  });

  test('rejects a second reward for the same completion', () {
    final first = engine.decide(
      baseXp: 10,
      alreadyAwardedForCompletion: false,
    );
    final second = engine.decide(
      baseXp: 10,
      alreadyAwardedForCompletion: true,
    );

    expect(first.isAwarded, isTrue);
    expect(second, const XpDecision.duplicate(baseXp: 10));
    expect(second.awardedXp, 0);
  });

  test('is deterministic for the same inputs', () {
    const first = XpEngine();
    const second = XpEngine();

    expect(
      first.decide(baseXp: 35, alreadyAwardedForCompletion: false),
      second.decide(baseXp: 35, alreadyAwardedForCompletion: false),
    );
    expect(
      first.decide(baseXp: 35, alreadyAwardedForCompletion: true),
      second.decide(baseXp: 35, alreadyAwardedForCompletion: true),
    );
    expect(
      first.decide(baseXp: 0, alreadyAwardedForCompletion: false),
      second.decide(baseXp: 0, alreadyAwardedForCompletion: false),
    );
  });

  test('does not apply multipliers yet', () {
    final decision = engine.decide(
      baseXp: 50,
      alreadyAwardedForCompletion: false,
    );

    expect(decision.awardedXp, decision.baseXp);
  });
}
