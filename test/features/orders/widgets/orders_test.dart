import 'package:cleanreactive/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// The status the feature is reporting, read off the screen.
String statusLabel(WidgetTester tester) {
  for (final text in tester.widgetList<Text>(find.byType(Text))) {
    final data = text.data;
    if (const ['idle', 'loading', 'fetching', 'mutating'].contains(data)) {
      return data!;
    }
  }
  return '<none>';
}

bool isProcessing(WidgetTester tester) =>
    find.byType(CircularProgressIndicator).evaluate().isNotEmpty;

void main() {
  testWidgets('reports what the feature is doing, at every stage', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pump();

    expect(statusLabel(tester), 'loading', reason: 'a first read, nothing yet');
    expect(isProcessing(tester), isTrue);

    await tester.pump(const Duration(seconds: 2));
    expect(statusLabel(tester), 'idle');
    expect(isProcessing(tester), isFalse);

    await tester.tap(find.text('2 items').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete Item').first);
    await tester.pump();

    expect(statusLabel(tester), 'mutating', reason: 'a write is in flight');
    expect(isProcessing(tester), isTrue);

    await tester.pump(const Duration(milliseconds: 1100));
    expect(
      statusLabel(tester),
      'fetching',
      reason: 'the write landed and the orders are read again',
    );
    expect(isProcessing(tester), isTrue);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(statusLabel(tester), 'idle');
    expect(isProcessing(tester), isFalse);
  });
}
