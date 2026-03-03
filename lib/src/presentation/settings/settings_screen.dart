import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/services/pdf_export_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authRepo = ref.watch(authRepositoryProvider);
    final tasks = ref.watch(taskListProvider).value ?? [];
    final settingsAsync = ref.watch(settingsServiceProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            value: true,
            onChanged: (_) {},
            title: const Text('Notifications'),
            subtitle: const Text('Remind me about upcoming deadlines'),
          ),
          settingsAsync.when(
            data: (settings) => SwitchListTile(
              value: settings.weeklyResetEnabled,
              onChanged: (value) => settings.setWeeklyReset(value),
              title: const Text('Weekly reset'),
              subtitle: const Text('Reset tower blocks every week'),
            ),
            loading: () => const ListTile(
              title: Text('Weekly reset'),
              subtitle: Text('Loading...'),
            ),
            error: (error, stack) => const ListTile(
              title: Text('Weekly reset'),
              subtitle: Text('Failed to load setting'),
            ),
          ),
          ListTile(
            title: const Text('Export data (PDF)'),
            subtitle: const Text('Generate a shareable PDF report'),
            trailing: const Icon(Icons.picture_as_pdf),
            onTap: () => PdfExportService.exportTasks(tasks),
          ),
          ListTile(
            title: const Text('Upgrade to Pro'),
            subtitle: const Text('Unlock advanced analytics & themes'),
            trailing: const Icon(Icons.lock_open),
            onTap: () => context.push('/paywall'),
          ),
          const Divider(),
          ListTile(
            title: const Text('Restore purchases'),
            onTap: () async {
              await ref.watch(purchaseRepositoryProvider).restore();
            },
          ),
          ListTile(
            title: const Text('Sign out'),
            onTap: () async {
              await authRepo.signOut();
            },
          ),
        ],
      ),
    );
  }
}
