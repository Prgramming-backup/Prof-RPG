import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/task.dart';
import '../services/date_display.dart';
import '../services/task_validator.dart';

class TaskEditorScreen extends StatefulWidget {
  const TaskEditorScreen({super.key, this.task});

  final Task? task;

  @override
  State<TaskEditorScreen> createState() => _TaskEditorScreenState();
}

class _TaskEditorScreenState extends State<TaskEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _validator = const TaskValidator();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _xpController;
  DateTime? _dueDate;
  var _submitted = false;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(
      text: task?.description ?? '',
    );
    _xpController = TextEditingController(
      text: task == null ? '' : '${task.xpReward}',
    );
    _dueDate = task?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _xpController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
    );
    if (selected != null) {
      setState(() => _dueDate = selected);
    }
  }

  void _save() {
    setState(() => _submitted = true);
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final draft = Task(
      id: widget.task?.id ?? '',
      title: _titleController.text.trim(),
      description: _validator.normalizeDescription(_descriptionController.text),
      xpReward: _validator.parseXp(_xpController.text),
      dueDate: _dueDate,
      isCompleted: widget.task?.isCompleted ?? false,
      createdAt: widget.task?.createdAt ?? DateTime.now(),
      completedAt: widget.task?.completedAt,
    );
    Navigator.of(context).pop(draft);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit quest' : 'New quest'),
        actions: [
          TextButton(
            key: const Key('save-task'),
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: _submitted
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              TextFormField(
                key: const Key('task-title-field'),
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Gym, studying, reading…',
                ),
                validator: (value) => _validator.titleError(value ?? ''),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('task-description-field'),
                controller: _descriptionController,
                minLines: 2,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('task-xp-field'),
                controller: _xpController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'XP reward',
                  helperText: 'Stored with the quest. XP is not awarded yet.',
                ),
                validator: (value) => _validator.xpError(value ?? ''),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_outlined),
                title: Text(
                  _dueDate == null
                      ? 'Due date (optional)'
                      : 'Due ${formatTaskDate(_dueDate!)}',
                ),
                trailing: _dueDate == null
                    ? TextButton(
                        onPressed: _pickDueDate,
                        child: const Text('Add'),
                      )
                    : TextButton(
                        onPressed: () => setState(() => _dueDate = null),
                        child: const Text('Clear'),
                      ),
                onTap: _pickDueDate,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
