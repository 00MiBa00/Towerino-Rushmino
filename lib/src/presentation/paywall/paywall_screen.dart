import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../widgets/demo_notice_banner.dart';
import '../widgets/section_header.dart';

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
              const DemoNoticeBanner(padding: EdgeInsets.only(bottom: 12)),
              const SectionHeader(
                title: 'Unlock Pro',
                subtitle:
                    'Advanced analytics, unlimited tasks, custom tower themes, and data export.',
                icon: Icons.workspace_premium,
                gradient: [
                  Color(0xFFFF8C6B),
                  Color(0xFFFFB36B),
                  Color(0xFFFFD27D),
                ],
              ),
              const SizedBox(height: 24),
              for (final product in products)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.auto_awesome,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.title,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              product.description,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: () => purchaseRepo.buy(product),
                        child: Text(product.price),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
