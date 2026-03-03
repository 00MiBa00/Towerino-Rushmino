import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../widgets/empty_state.dart';
import '../widgets/tower_widget.dart';

class TowerScreen extends ConsumerWidget {
  const TowerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskListAsync = ref.watch(taskListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tower'),
      ),
      body: taskListAsync.when(
        data: (tasks) {
          final completed = tasks.where((t) => t.isCompleted).toList()
            ..sort((a, b) =>
                (a.completedAt ?? a.createdAt).compareTo(b.completedAt ?? b.createdAt));
          if (completed.isEmpty) {
            return const EmptyState(
              title: 'No completed tasks',
              subtitle: 'Complete tasks to build your tower blocks.',
            );
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: TowerWidget(tasks: completed),
                ),
                const SizedBox(height: 12),
                Text(
                  'Blocks: ${completed.length}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
