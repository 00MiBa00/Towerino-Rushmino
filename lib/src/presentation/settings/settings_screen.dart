import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../app/providers.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_category.dart';
import '../../domain/entities/task_priority.dart';
import '../../core/services/pdf_export_service.dart';
import '../widgets/demo_notice_banner.dart';
import '../widgets/section_header.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authRepo = ref.watch(authRepositoryProvider);
    final taskRepo = ref.watch(taskRepositoryProvider);
    final tasks = ref.watch(taskListProvider).value ?? [];
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const DemoNoticeBanner(padding: EdgeInsets.only(bottom: 12)),
          const SectionHeader(
            title: 'Personalize your flow',
            subtitle: 'Manage your data and account preferences.',
            icon: Icons.tune,
            gradient: [
              Color(0xFF5B6CFF),
              Color(0xFF7F5CFF),
              Color(0xFFB95CFF),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Export data (PDF)'),
                  subtitle: const Text('Generate a shareable PDF report'),
                  trailing: const Icon(Icons.picture_as_pdf),
                  onTap: () async {
                    if (tasks.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No tasks to export yet.')),
                      );
                      return;
                    }
                    try {
                      await PdfExportService.exportTasks(tasks);
                    } catch (error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Export failed: $error')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Add demo tasks'),
                  subtitle: const Text('Populate the app with sample data'),
                  trailing: const Icon(Icons.auto_awesome),
                  onTap: () async {
                    final demoTasks = _buildDemoTasks();
                    for (final task in demoTasks) {
                      await taskRepo.addTask(task);
                    }
                    final settings = await ref.read(settingsServiceProvider.future);
                    await settings.setDemoDataEnabled(true);
                    ref.invalidate(settingsServiceProvider);
                    ref.invalidate(demoModeProvider);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Demo tasks added.')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Sign out'),
                  onTap: () async {
                    try {
                      await authRepo.signOut();
                    } catch (error) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Sign out failed: $error')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

List<Task> _buildDemoTasks() {
  final now = DateTime.now();
  return [
    Task(
      id: const Uuid().v4(),
      title: 'Design tower skins',
      description: 'Create 3 visual themes for the tower blocks.',
      category: TaskCategory.work,
      priority: TaskPriority.high,
      dueAt: now.add(const Duration(hours: 6)),
      createdAt: now.subtract(const Duration(days: 1)),
    ),
    Task(
      id: const Uuid().v4(),
      title: 'Morning workout',
      description: '30 minutes of strength + mobility.',
      category: TaskCategory.health,
      priority: TaskPriority.medium,
      dueAt: now.subtract(const Duration(hours: 4)),
      isCompleted: true,
      completedAt: now.subtract(const Duration(hours: 1)),
      createdAt: now.subtract(const Duration(days: 2)),
    ),
    Task(
      id: const Uuid().v4(),
      title: 'Read 10 pages',
      description: 'Finish the next chapter.',
      category: TaskCategory.study,
      priority: TaskPriority.low,
      dueAt: now.add(const Duration(days: 1)),
      isCompleted: true,
      completedAt: now.subtract(const Duration(hours: 3)),
      createdAt: now.subtract(const Duration(days: 3)),
    ),
    Task(
      id: const Uuid().v4(),
      title: 'Call family',
      description: 'Check in for the week.',
      category: TaskCategory.personal,
      priority: TaskPriority.medium,
      dueAt: now.add(const Duration(days: 2)),
      createdAt: now.subtract(const Duration(days: 1)),
    ),
    Task(
      id: const Uuid().v4(),
      title: 'Sprint planning',
      description: 'Map the next 5 tasks for the week.',
      category: TaskCategory.work,
      priority: TaskPriority.high,
      dueAt: now.add(const Duration(hours: 12)),
      isCompleted: true,
      completedAt: now.subtract(const Duration(hours: 2)),
      createdAt: now.subtract(const Duration(days: 4)),
    ),
    Task(
      id: const Uuid().v4(),
      title: 'Hydration streak',
      description: 'Drink 2L of water today.',
      category: TaskCategory.health,
      priority: TaskPriority.low,
      dueAt: now.add(const Duration(hours: 8)),
      createdAt: now.subtract(const Duration(days: 1)),
    ),
    Task(
      id: const Uuid().v4(),
      title: 'Custom ritual',
      description: 'Set a calming evening routine.',
      category: TaskCategory.custom,
      priority: TaskPriority.medium,
      dueAt: now.add(const Duration(days: 3)),
      createdAt: now.subtract(const Duration(days: 2)),
    ),
  ];
}
