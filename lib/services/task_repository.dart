import '../models/task.dart';

abstract class TaskRepository {
  List<Task> getAll();

  Task create({
    required String title,
    String? description,
    required int xpReward,
    DateTime? dueDate,
  });

  Task update(Task task);

  Task complete(String id, {DateTime? completedAt});

  Task uncomplete(String id);

  void delete(String id);
}

class InMemoryTaskRepository implements TaskRepository {
  InMemoryTaskRepository({List<Task>? seed, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now {
    if (seed != null) {
      _tasks.addAll(seed);
    }
  }

  final DateTime Function() _clock;
  final List<Task> _tasks = [];
  int _nextId = 1;

  @override
  List<Task> getAll() => List.unmodifiable(_tasks);

  @override
  Task create({
    required String title,
    String? description,
    required int xpReward,
    DateTime? dueDate,
  }) {
    final task = Task(
      id: 'task_${_nextId++}',
      title: title,
      description: description,
      xpReward: xpReward,
      dueDate: dueDate,
      createdAt: _clock(),
    );
    _tasks.add(task);
    return task;
  }

  @override
  Task update(Task task) {
    final index = _indexOf(task.id);
    _tasks[index] = task;
    return task;
  }

  @override
  Task complete(String id, {DateTime? completedAt}) {
    final index = _indexOf(id);
    final current = _tasks[index];
    if (current.isCompleted) {
      return current;
    }

    final completed = current.copyWith(
      isCompleted: true,
      completedAt: completedAt ?? _clock(),
    );
    _tasks[index] = completed;
    return completed;
  }

  @override
  Task uncomplete(String id) {
    final index = _indexOf(id);
    final current = _tasks[index];
    if (!current.isCompleted) {
      return current;
    }

    final reopened = current.copyWith(
      isCompleted: false,
      clearCompletedAt: true,
    );
    _tasks[index] = reopened;
    return reopened;
  }

  @override
  void delete(String id) {
    final index = _indexOf(id);
    _tasks.removeAt(index);
  }

  int _indexOf(String id) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index < 0) {
      throw StateError('Task not found: $id');
    }
    return index;
  }
}
