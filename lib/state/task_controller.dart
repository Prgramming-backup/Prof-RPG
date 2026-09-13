import 'package:flutter/foundation.dart';

import '../models/avatar_progression.dart';
import '../models/task.dart';
import '../models/xp_transaction.dart';
import '../services/avatar_engine.dart';
import '../services/level_engine.dart';
import '../services/streak_engine.dart';
import '../services/task_repository.dart';
import '../services/xp_completion_id.dart';
import '../services/xp_ledger.dart';

class TaskController extends ChangeNotifier {
  TaskController(
    this._repository, {
    XpLedger? xpLedger,
    StreakEngine? streakEngine,
    LevelEngine? levelEngine,
    AvatarEngine? avatarEngine,
    DateTime Function()? clock,
  }) : _xpLedger = xpLedger ?? InMemoryXpLedger(),
       _streakEngine = streakEngine ?? const StreakEngine(),
       _levelEngine = levelEngine ?? const LevelEngine(),
       _avatarEngine = avatarEngine ?? const AvatarEngine(),
       _clock = clock ?? DateTime.now;

  final TaskRepository _repository;
  final XpLedger _xpLedger;
  final StreakEngine _streakEngine;
  final LevelEngine _levelEngine;
  final AvatarEngine _avatarEngine;
  final DateTime Function() _clock;

  List<Task> get tasks => _repository.getAll();

  List<Task> get activeTasks =>
      tasks.where((task) => !task.isCompleted).toList(growable: false);

  List<Task> get completedTasks =>
      tasks.where((task) => task.isCompleted).toList(growable: false);

  bool get isEmpty => tasks.isEmpty;

  int get totalXp => _xpLedger.totalXp;

  LevelProgress get levelProgress => _levelEngine.progressFor(totalXp);

  AvatarProgression get avatarProgression =>
      _avatarEngine.progressionFor(levelProgress.level);

  List<XpTransaction> get xpTransactions => _xpLedger.transactions;

  StreakInfo streakInfo([DateTime? today]) {
    final dates = _completionDates.toList(growable: false);
    return _streakEngine.calculate(
      completionDates: dates,
      today: today ?? _clock(),
    );
  }

  int get currentStreak => streakInfo().streakLength;

  double get currentMultiplier => streakInfo().currentMultiplier;

  Task createTask({
    required String title,
    String? description,
    required int xpReward,
    DateTime? dueDate,
  }) {
    final task = _repository.create(
      title: title.trim(),
      description: description,
      xpReward: xpReward,
      dueDate: dueDate,
    );
    notifyListeners();
    return task;
  }

  Task updateTask(Task task) {
    final updated = _repository.update(task);
    notifyListeners();
    return updated;
  }

  Task completeTask(String id, {DateTime? completedAt}) {
    final completed = _repository.complete(
      id,
      completedAt: completedAt ?? _clock(),
    );
    _awardXpFor(completed);
    notifyListeners();
    return completed;
  }

  Task uncompleteTask(String id) {
    final current = tasks.firstWhere((task) => task.id == id);
    final completionId = _completionIdOf(current);
    final reopened = _repository.uncomplete(id);
    if (completionId != null) {
      _xpLedger.reverseForCompletion(completionId);
    }
    notifyListeners();
    return reopened;
  }

  void deleteTask(String id) {
    _repository.delete(id);
    notifyListeners();
  }

  void _awardXpFor(Task task) {
    final completedAt = task.completedAt;
    if (!task.isCompleted || completedAt == null) {
      return;
    }
    final completionId = _completionIdOf(task);
    if (completionId == null) {
      return;
    }

    final streakInfo = _streakEngine.calculate(
      completionDates: _completionDates,
      today: completedAt,
    );
    final multiplier = streakInfo.currentMultiplier;

    _xpLedger.award(
      sourceTaskId: task.id,
      baseXp: task.xpReward,
      completionId: completionId,
      multiplier: multiplier,
      timestamp: completedAt,
    );
  }

  Iterable<DateTime> get _completionDates sync* {
    for (final t in tasks) {
      if (t.isCompleted && t.completedAt != null) {
        yield t.completedAt!;
      }
    }
    for (final tx in _xpLedger.transactions) {
      if (!tx.reversed) {
        yield tx.timestamp;
      }
    }
  }

  String? _completionIdOf(Task task) {
    final completedAt = task.completedAt;
    if (!task.isCompleted || completedAt == null) {
      return null;
    }
    return xpCompletionId(taskId: task.id, completedAt: completedAt);
  }
}
