import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';

class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authRepositoryProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign in'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Towerino Rushmino',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'Build your productivity tower with completed tasks.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: () async {
                await auth.signInWithGoogle();
              },
              icon: const Icon(Icons.account_circle),
              label: const Text('Continue with Google'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () async {
                await auth.signInAnonymously();
              },
              child: const Text('Continue anonymously'),
            ),
          ],
        ),
      ),
    );
  }
}
