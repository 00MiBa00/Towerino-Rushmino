import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/constants.dart';
import '../widgets/empty_state.dart';
import '../widgets/task_tile.dart';

final rushModeProvider = Provider<bool>((ref) {
  final tasks = ref.watch(taskListProvider).value ?? [];
  final overdueCount = tasks.where((task) => task.isOverdue).length;
  return overdueCount >= AppConstants.rushModeOverdueThreshold;
});

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskListAsync = ref.watch(taskListProvider);
    final rushMode = ref.watch(rushModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          if (rushMode)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Chip(
                label: const Text('Rush Mode'),
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
              ),
            ),
        ],
      ),
      body: taskListAsync.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return const EmptyState(
              title: 'No tasks yet',
              subtitle: 'Create a task to start building your tower.',
            );
          }
          final sorted = [...tasks]..sort((a, b) => a.dueAt.compareTo(b.dueAt));
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: sorted.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final task = sorted[index];
              return TaskTile(task: task);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/tasks/new'),
        icon: const Icon(Icons.add),
        label: const Text('New task'),
      ),
    );
  }
}
