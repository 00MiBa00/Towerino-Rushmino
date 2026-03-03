import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../home/home_shell.dart';
import 'sign_in_screen.dart';

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  late final ProviderSubscription _authStateSub;

  @override
  void initState() {
    super.initState();
    _authStateSub = ref.listenManual(authStateProvider, (previous, next) {
      final user = next.valueOrNull;
      if (user != null) {
        ref.read(taskRepositoryProvider).syncFromRemote();
      }
    });
  }

  @override
  void dispose() {
    _authStateSub.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          return const SignInScreen();
        }
        return const HomeShell();
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Text('Auth error: $error'),
        ),
      ),
    );
  }
}
