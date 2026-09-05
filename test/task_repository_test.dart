import 'package:flutter_test/flutter_test.dart';

import 'package:prod/services/task_repository.dart';

void main() {
  late InMemoryTaskRepository repository;

  setUp(() {
    repository = InMemoryTaskRepository();
  });

  test('creates and lists tasks', () {
    repository.create(title: 'Gym', xpReward: 10);
    repository.create(
      title: 'Study',
      description: 'Chapter 4',
      xpReward: 20,
      dueDate: DateTime(2026, 9, 6),
    );

    expect(repository.getAll(), hasLength(2));
    expect(repository.getAll().first.title, 'Gym');
    expect(repository.getAll().last.description, 'Chapter 4');
  });

  test('completes a task without changing XP reward', () {
    final created = repository.create(title: 'Walk', xpReward: 10);

    final completed = repository.complete(created.id);

    expect(completed.isCompleted, isTrue);
    expect(completed.completedAt, isNotNull);
    expect(completed.xpReward, 10);
    expect(repository.complete(created.id).id, created.id);
  });

  test('updates and deletes a task', () {
    final created = repository.create(title: 'Read', xpReward: 15);
    final updated = repository.update(
      created.copyWith(title: 'Read 20 pages', xpReward: 20),
    );

    expect(updated.title, 'Read 20 pages');
    expect(updated.xpReward, 20);

    repository.delete(created.id);
    expect(repository.getAll(), isEmpty);
  });

  test('throws when the task does not exist', () {
    expect(() => repository.complete('missing'), throwsStateError);
    expect(() => repository.delete('missing'), throwsStateError);
  });
}
