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
    double multiplier = 1.0,
    DateTime? timestamp,
  });

  XpTransaction? reverseForCompletion(String completionId);

  dynamic replaceAll(List<XpTransaction> transactions);
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
    double multiplier = 1.0,
    DateTime? timestamp,
  }) {
    final alreadyAwarded = _hasActiveAward(completionId);
    final decision = _engine.decide(
      baseXp: baseXp,
      alreadyAwardedForCompletion: alreadyAwarded,
      multiplier: multiplier,
    );

    if (!decision.isAwarded) {
      return XpAwardResult(decision: decision);
    }

    final transaction = XpTransaction(
      id: 'xp_${_nextId++}',
      sourceTaskId: sourceTaskId,
      completionId: completionId,
      baseXp: decision.baseXp,
      multiplier: decision.multiplier,
      awardedXp: decision.awardedXp,
      timestamp: timestamp ?? _clock(),
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

  @override
  void replaceAll(List<XpTransaction> transactions) {
    _transactions.clear();
    _transactions.addAll(transactions);
    _syncNextId();
  }

  void _syncNextId() {
    var maxId = 0;
    for (final tx in _transactions) {
      if (tx.id.startsWith('xp_')) {
        final parsed = int.tryParse(tx.id.substring(3));
        if (parsed != null && parsed > maxId) {
          maxId = parsed;
        }
      }
    }
    _nextId = maxId + 1;
  }

  bool _hasActiveAward(String completionId) {
    return _transactions.any(
      (transaction) =>
          transaction.completionId == completionId && !transaction.reversed,
    );
  }
}
