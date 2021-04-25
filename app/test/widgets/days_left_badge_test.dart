import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player/generated/l10n.dart';
import 'package:player/widgets/days_left_badge.dart';

void main() {
  group(DaysLeftBadge, () {
    testWidgets('displays the number of days remaining', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: [S.delegate],
          supportedLocales: S.delegate.supportedLocales,
          home: Material(
            child: Center(
              child: DaysLeftBadge(
                showDate: DateTime.now(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Chip), findsOneWidget);
      expect(find.text('28 Days Left'), findsOneWidget);
    });
    testWidgets('does not show negative numbers', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: [S.delegate],
          supportedLocales: S.delegate.supportedLocales,
          home: Material(
            child: Center(
              child: DaysLeftBadge(
                showDate: DateTime.now().subtract(const Duration(days: 40)),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Chip), findsOneWidget);
      expect(find.text('0 Days Left'), findsOneWidget);
    });
  });
}
