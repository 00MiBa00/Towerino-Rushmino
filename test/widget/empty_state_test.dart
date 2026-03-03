import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:towerino_rushmino/src/presentation/widgets/empty_state.dart';

void main() {
  testWidgets('empty state renders title and subtitle', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: EmptyState(title: 'Title', subtitle: 'Subtitle'),
      ),
    );

    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Subtitle'), findsOneWidget);
  });
}
