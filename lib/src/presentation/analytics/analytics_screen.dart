import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/entities/task.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskListAsync = ref.watch(taskListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: taskListAsync.when(
        data: (tasks) {
          final stats = _TaskStats.fromTasks(tasks);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _StatCard(title: 'Completion rate', value: '${stats.completionRate}%'),
              const SizedBox(height: 12),
              _StatCard(title: 'Current streak', value: '${stats.currentStreak} days'),
              const SizedBox(height: 12),
              _StatCard(title: 'Monthly tasks', value: '${stats.monthlyTasks}'),
              const SizedBox(height: 12),
              _StatCard(title: 'Most productive category', value: stats.topCategory),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ),
    );
  }
}

class _TaskStats {
  _TaskStats({
    required this.completionRate,
    required this.currentStreak,
    required this.monthlyTasks,
    required this.topCategory,
  });

  final int completionRate;
  final int currentStreak;
  final int monthlyTasks;
  final String topCategory;

  factory _TaskStats.fromTasks(List<Task> tasks) {
    if (tasks.isEmpty) {
      return _TaskStats(
        completionRate: 0,
        currentStreak: 0,
        monthlyTasks: 0,
        topCategory: 'N/A',
      );
    }
    final completed = tasks.where((t) => t.isCompleted).toList();
    final completionRate = ((completed.length / tasks.length) * 100).round();
    final now = DateTime.now();
    final monthlyTasks = tasks.where((t) => t.createdAt.month == now.month).length;

    final categoryCounts = <String, int>{};
    for (final task in completed) {
      categoryCounts.update(task.category.name, (value) => value + 1,
          ifAbsent: () => 1);
    }
    final topCategory = categoryCounts.entries.isEmpty
        ? 'N/A'
        : (categoryCounts.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value)))
            .first
            .key;

    final streak = _calculateStreak(completed);

    return _TaskStats(
      completionRate: completionRate,
      currentStreak: streak,
      monthlyTasks: monthlyTasks,
      topCategory: topCategory,
    );
  }

  static int _calculateStreak(List<Task> completed) {
    final dates = completed
        .where((t) => t.completedAt != null)
        .map((t) => DateTime(t.completedAt!.year, t.completedAt!.month, t.completedAt!.day))
        .toSet()
        .toList()
      ..sort();

    if (dates.isEmpty) return 0;
    int streak = 1;
    for (int i = dates.length - 1; i > 0; i--) {
      final difference = dates[i].difference(dates[i - 1]).inDays;
      if (difference == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }
}
