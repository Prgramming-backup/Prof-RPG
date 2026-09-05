import 'package:flutter/foundation.dart';

import '../models/task.dart';
import '../services/task_repository.dart';

class TaskController extends ChangeNotifier {
  TaskController(this._repository);

  final TaskRepository _repository;

  List<Task> get tasks => _repository.getAll();

  List<Task> get activeTasks =>
      tasks.where((task) => !task.isCompleted).toList(growable: false);

  List<Task> get completedTasks =>
      tasks.where((task) => task.isCompleted).toList(growable: false);

  bool get isEmpty => tasks.isEmpty;

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
    notifyListeners();
    return completed;
  }

  void deleteTask(String id) {
    _repository.delete(id);
    notifyListeners();
  }
}
