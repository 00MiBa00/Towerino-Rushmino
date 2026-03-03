import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchaseRepo = ref.watch(purchaseRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Towerino Pro')),
      body: FutureBuilder(
        future: purchaseRepo.fetchProducts(),
        builder: (context, snapshot) {
          final products = snapshot.data ?? [];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Unlock Pro',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Advanced analytics, unlimited tasks, custom tower themes, and data export.',
              ),
              const SizedBox(height: 24),
              for (final product in products)
                Card(
                  child: ListTile(
                    title: Text(product.title),
                    subtitle: Text(product.description),
                    trailing: Text(product.price),
                    onTap: () => purchaseRepo.buy(product),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
