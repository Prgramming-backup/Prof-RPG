import 'package:flutter/material.dart';

import 'navigation/app_shell.dart';
import 'services/task_repository.dart';
import 'state/task_controller.dart';
import 'state/task_scope.dart';
import 'theme/app_theme.dart';

class ProRpgApp extends StatefulWidget {
  const ProRpgApp({
    super.key,
    this.taskRepository,
  });

  final TaskRepository? taskRepository;

  @override
  State<ProRpgApp> createState() => _ProRpgAppState();
}

class _ProRpgAppState extends State<ProRpgApp> {
  late final TaskController _taskController;

  @override
  void initState() {
    super.initState();
    _taskController = TaskController(
      widget.taskRepository ?? InMemoryTaskRepository(),
    );
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TaskScope(
      controller: _taskController,
      child: MaterialApp(
        title: 'Pro-RPG',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const AppShell(),
      ),
    );
  }
}
