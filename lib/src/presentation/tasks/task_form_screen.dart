import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../app/providers.dart';
import '../../core/extensions/date_time_x.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_category.dart';
import '../../domain/entities/task_priority.dart';

class TaskFormScreen extends ConsumerStatefulWidget {
  const TaskFormScreen({super.key, this.taskId});

  final String? taskId;

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  TaskCategory _category = TaskCategory.work;
  TaskPriority _priority = TaskPriority.medium;
  DateTime _dueAt = DateTime.now().add(const Duration(hours: 2));
  Task? _editingTask;
  bool _didInit = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInit) return;
    _didInit = true;
    final taskId = widget.taskId;
    if (taskId != null) {
      final tasks = ref.read(taskListProvider).value ?? [];
      final task = tasks.firstWhere(
        (t) => t.id == taskId,
        orElse: () => tasks.isNotEmpty ? tasks.first : _emptyTask(),
      );
      _editingTask = task;
      _titleController.text = task.title;
      _descriptionController.text = task.description ?? '';
      _category = task.category;
      _priority = task.priority;
      _dueAt = task.dueAt;
    }
  }

  Task _emptyTask() {
    return Task(
      id: const Uuid().v4(),
      title: '',
      category: TaskCategory.work,
      priority: TaskPriority.medium,
      dueAt: DateTime.now().add(const Duration(hours: 2)),
      createdAt: DateTime.now(),
    );
  }

  Future<void> _pickDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueAt,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dueAt),
    );
    if (time == null) return;
    setState(() {
      _dueAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(taskRepositoryProvider);
    final isEditing = widget.taskId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit task' : 'New task'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Enter a title' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<TaskCategory>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: TaskCategory.values
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category.name),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _category = value!),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<TaskPriority>(
              value: _priority,
              decoration: const InputDecoration(labelText: 'Priority'),
              items: TaskPriority.values
                  .map((priority) => DropdownMenuItem(
                        value: priority,
                        child: Text(priority.name),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _priority = value!),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Deadline'),
              subtitle: Text(_dueAt.formatShort()),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDueDate,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                final now = DateTime.now();
                final base = _editingTask;
                final task = Task(
                  id: widget.taskId ?? const Uuid().v4(),
                  title: _titleController.text,
                  description: _descriptionController.text,
                  category: _category,
                  priority: _priority,
                  dueAt: _dueAt,
                  createdAt: base?.createdAt ?? now,
                  updatedAt: now,
                  isCompleted: base?.isCompleted ?? false,
                  completedAt: base?.completedAt,
                  tags: base?.tags ?? const [],
                  recurrence: base?.recurrence,
                  isArchived: base?.isArchived ?? false,
                );
                if (isEditing) {
                  await repo.updateTask(task);
                } else {
                  await repo.addTask(task);
                }
                if (context.mounted) context.pop();
              },
              child: Text(isEditing ? 'Save changes' : 'Create task'),
            ),
          ],
        ),
      ),
    );
  }
}
