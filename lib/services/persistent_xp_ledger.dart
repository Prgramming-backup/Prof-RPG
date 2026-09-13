import 'dart:convert';

import '../models/xp_transaction.dart';
import 'persistence_service.dart';
import 'xp_engine.dart';
import 'xp_ledger.dart';

/// An [XpLedger] implementation that transparently persists XP transactions
/// using a [PersistenceService].
///
/// Keeps an in-memory cache for fast, synchronous calculations and asynchronously
/// writes transactions to storage whenever XP is awarded or reversed.
class PersistentXpLedger implements XpLedger {
  PersistentXpLedger({
    required PersistenceService persistenceService,
    String storageKey = defaultStorageKey,
    XpEngine engine = const XpEngine(),
    DateTime Function()? clock,
    List<XpTransaction>? initialTransactions,
  })  : _persistenceService = persistenceService, // ignore: prefer_initializing_formals
        _storageKey = storageKey, // ignore: prefer_initializing_formals
        _engine = engine, // ignore: prefer_initializing_formals
        _clock = clock ?? DateTime.now {
    if (initialTransactions != null) {
      _transactions.addAll(initialTransactions);
      _syncNextId();
    }
  }

  /// Default storage key used in [PersistenceService].
  static const String defaultStorageKey = 'pro_rpg_xp_transactions';

  final PersistenceService _persistenceService;
  final String _storageKey;
  final XpEngine _engine;
  final DateTime Function() _clock;
  final List<XpTransaction> _transactions = [];
  int _nextId = 1;

  /// Loads persisted transactions from [PersistenceService] into memory.
  Future<void> loadFromPersistence() async {
    final rawJson = await _persistenceService.getString(_storageKey);
    if (rawJson == null || rawJson.trim().isEmpty) {
      return;
    }
    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is List) {
        _transactions.clear();
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            _transactions.add(XpTransaction.fromJson(item));
          }
        }
        _syncNextId();
      }
    } catch (_) {
      // Ignore corrupted cache; retain existing state safely.
    }
  }

  /// Replaces the current transactions list completely (used by backup restoration)
  /// and commits to persistence.
  @override
  Future<void> replaceAll(List<XpTransaction> newTransactions) async {
    _transactions.clear();
    _transactions.addAll(newTransactions);
    _syncNextId();
    await _saveToPersistence();
  }

  @override
  List<XpTransaction> get transactions => List.unmodifiable(_transactions);

  @override
  int get totalXp {
    var total = 0;
    for (final tx in _transactions) {
      if (!tx.reversed) {
        total += tx.awardedXp;
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
    _saveToPersistence();
    return XpAwardResult(decision: decision, transaction: transaction);
  }

  @override
  XpTransaction? reverseForCompletion(String completionId) {
    final index = _transactions.indexWhere(
      (tx) => tx.completionId == completionId && !tx.reversed,
    );
    if (index < 0) {
      return null;
    }

    final reversed = _transactions[index].reversedCopy();
    _transactions[index] = reversed;
    _saveToPersistence();
    return reversed;
  }

  bool _hasActiveAward(String completionId) {
    return _transactions.any(
      (tx) => tx.completionId == completionId && !tx.reversed,
    );
  }

  Future<void> _saveToPersistence() async {
    final rawJson = jsonEncode(_transactions.map((tx) => tx.toJson()).toList());
    await _persistenceService.setString(_storageKey, rawJson);
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
}
