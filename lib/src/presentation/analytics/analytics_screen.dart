import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/entities/task.dart';
import '../widgets/demo_notice_banner.dart';
import '../widgets/section_header.dart';

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
              const DemoNoticeBanner(padding: EdgeInsets.only(bottom: 12)),
              const SectionHeader(
                title: 'Progress insights',
                subtitle: 'Track momentum and stay ahead of your goals.',
                icon: Icons.insights,
                gradient: [
                  Color(0xFF6D5BFF),
                  Color(0xFF9A6BFF),
                  Color(0xFFDA8BFF),
                ],
              ),
              const SizedBox(height: 16),
              _StatCard(
                title: 'Completion rate',
                value: '${stats.completionRate}%',
                icon: Icons.stacked_line_chart,
                gradient: const [Color(0xFF5B6CFF), Color(0xFF8A7CFF)],
              ),
              const SizedBox(height: 12),
              _StatCard(
                title: 'Current streak',
                value: '${stats.currentStreak} days',
                icon: Icons.local_fire_department,
                gradient: const [Color(0xFFFF8C6B), Color(0xFFFFB36B)],
              ),
              const SizedBox(height: 12),
              _StatCard(
                title: 'Monthly tasks',
                value: '${stats.monthlyTasks}',
                icon: Icons.calendar_month,
                gradient: const [Color(0xFF37A97A), Color(0xFF6EDC9D)],
              ),
              const SizedBox(height: 12),
              _StatCard(
                title: 'Top category',
                value: stats.topCategory,
                icon: Icons.star_rounded,
                gradient: const [Color(0xFF2EC4FF), Color(0xFF6EDCFF)],
              ),
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
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  final String title;
  final String value;
  final IconData icon;
  final List<Color> gradient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient.last.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
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
