import 'package:flutter/material.dart';

import 'task_controller.dart';

class TaskScope extends InheritedNotifier<TaskController> {
  const TaskScope({
    super.key,
    required TaskController controller,
    required super.child,
  }) : super(notifier: controller);

  static TaskController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<TaskScope>();
    assert(scope != null, 'TaskScope not found in the widget tree.');
    return scope!.notifier!;
  }
}
