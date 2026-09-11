import '../models/xp_transaction.dart';
import 'xp_engine.dart';

class XpAwardResult {
  const XpAwardResult({required this.decision, this.transaction});

  final XpDecision decision;
  final XpTransaction? transaction;

  bool get isAwarded => decision.isAwarded;
}

abstract class XpLedger {
  List<XpTransaction> get transactions;

  int get totalXp;

  XpAwardResult award({
    required String sourceTaskId,
    required int baseXp,
    required String completionId,
  });

  XpTransaction? reverseForCompletion(String completionId);
}

class InMemoryXpLedger implements XpLedger {
  InMemoryXpLedger({
    this._engine = const XpEngine(),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final XpEngine _engine;
  final DateTime Function() _clock;
  final List<XpTransaction> _transactions = [];
  int _nextId = 1;

  @override
  List<XpTransaction> get transactions => List.unmodifiable(_transactions);

  @override
  int get totalXp {
    var total = 0;
    for (final transaction in _transactions) {
      if (!transaction.reversed) {
        total += transaction.awardedXp;
      }
    }
    return total;
  }

  @override
  XpAwardResult award({
    required String sourceTaskId,
    required int baseXp,
    required String completionId,
  }) {
    final alreadyAwarded = _hasActiveAward(completionId);
    final decision = _engine.decide(
      baseXp: baseXp,
      alreadyAwardedForCompletion: alreadyAwarded,
    );

    if (!decision.isAwarded) {
      return XpAwardResult(decision: decision);
    }

    final transaction = XpTransaction(
      id: 'xp_${_nextId++}',
      sourceTaskId: sourceTaskId,
      completionId: completionId,
      baseXp: decision.baseXp,
      awardedXp: decision.awardedXp,
      timestamp: _clock(),
    );
    _transactions.add(transaction);
    return XpAwardResult(decision: decision, transaction: transaction);
  }

  @override
  XpTransaction? reverseForCompletion(String completionId) {
    final index = _transactions.indexWhere(
      (transaction) =>
          transaction.completionId == completionId && !transaction.reversed,
    );
    if (index < 0) {
      return null;
    }

    final reversed = _transactions[index].reversedCopy();
    _transactions[index] = reversed;
    return reversed;
  }

  bool _hasActiveAward(String completionId) {
    return _transactions.any(
      (transaction) =>
          transaction.completionId == completionId && !transaction.reversed,
    );
  }
}
