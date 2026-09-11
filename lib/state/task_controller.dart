import 'package:flutter/foundation.dart';

import '../models/task.dart';
import '../models/xp_transaction.dart';
import '../services/task_repository.dart';
import '../services/xp_completion_id.dart';
import '../services/xp_ledger.dart';

class TaskController extends ChangeNotifier {
  TaskController(this._repository, {XpLedger? xpLedger})
    : _xpLedger = xpLedger ?? InMemoryXpLedger();

  final TaskRepository _repository;
  final XpLedger _xpLedger;

  List<Task> get tasks => _repository.getAll();

  List<Task> get activeTasks =>
      tasks.where((task) => !task.isCompleted).toList(growable: false);

  List<Task> get completedTasks =>
      tasks.where((task) => task.isCompleted).toList(growable: false);

  bool get isEmpty => tasks.isEmpty;

  int get totalXp => _xpLedger.totalXp;

  List<XpTransaction> get xpTransactions => _xpLedger.transactions;

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

  Task completeTask(String id) {
    final completed = _repository.complete(id);
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
    final completionId = _completionIdOf(task);
    if (completionId == null) {
      return;
    }
    _xpLedger.award(
      sourceTaskId: task.id,
      baseXp: task.xpReward,
      completionId: completionId,
    );
  }

  String? _completionIdOf(Task task) {
    final completedAt = task.completedAt;
    if (!task.isCompleted || completedAt == null) {
      return null;
    }
    return xpCompletionId(taskId: task.id, completedAt: completedAt);
  }
}
