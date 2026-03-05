import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:product_catalog_app/design_system/design_system.dart';

void main() {
  group('CategoryChip', () {
    testWidgets('shows label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryChip(
              label: 'Smartphones',
              selected: false,
              onTap: () {},
            ),
          ),
        ),
      );
      expect(find.text('Smartphones'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryChip(
              label: 'All',
              selected: false,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      await tester.tap(find.text('All'));
      await tester.pump();
      expect(tapped, true);
    });

    testWidgets('renders in selected and unselected state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                CategoryChip(
                  label: 'Selected',
                  selected: true,
                  onTap: () {},
                ),
                CategoryChip(
                  label: 'Unselected',
                  selected: false,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      );
      expect(find.text('Selected'), findsOneWidget);
      expect(find.text('Unselected'), findsOneWidget);
    });
  });
}
