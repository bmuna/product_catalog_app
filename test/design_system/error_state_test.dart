import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:product_catalog_app/design_system/design_system.dart';

void main() {
  group('ErrorState', () {
    testWidgets('shows message and retry button', (tester) async {
      var retried = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorState(
              message: 'Something went wrong',
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(retried, true);
    });

    testWidgets('shows custom message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorState(message: 'Network error'),
          ),
        ),
      );
      expect(find.text('Network error'), findsOneWidget);
    });

    testWidgets('does not show retry when onRetry is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorState(message: 'Error', onRetry: null),
          ),
        ),
      );
      expect(find.text('Retry'), findsNothing);
    });
  });
}
