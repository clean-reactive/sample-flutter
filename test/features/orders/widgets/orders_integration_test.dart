import 'dart:async';

import 'package:cleanreactive/features/orders/repositories/order_entities.dart';
import 'package:cleanreactive/features/orders/repositories/orders_service.dart';
import 'package:cleanreactive/features/orders/widgets/order/order.dart';
import 'package:cleanreactive/features/orders/widgets/orders.dart';
import 'package:cleanreactive/features/orders/widgets/pill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../orders_factory.dart';
import '../repositories/mock_orders_gateway.dart';

/// The feature with only its resource stood in for.
///
/// Everything between the gateway and the screen is real — repository,
/// selectors, presenters — because what a scenario checks is that they add up
/// to what a user sees.
Future<void> pumpOrders(WidgetTester tester, MockOrdersGateway gateway) =>
    tester.pumpWidget(
      ProviderScope(
        overrides: [ordersGatewayProvider.overrideWithValue(gateway)],
        child: const MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: Orders())),
        ),
      ),
    );

/// What the resource holds once a read lands.
///
/// Three orders between two users, four items between them, fourteen items
/// counting quantity — four numbers no two of which are equal, so a unit that
/// renders the wrong projection cannot pass by coincidence.
final ordersMock = [
  makeOrder(
    'order-1',
    userId: 'user-a',
    items: [makeItem('item-1', quantity: 2), makeItem('item-2', quantity: 5)],
  ),
  makeOrder(
    'order-2',
    userId: 'user-b',
    items: [makeItem('item-3', quantity: 3)],
  ),
  makeOrder(
    'order-3',
    userId: 'user-a',
    items: [makeItem('item-4', quantity: 4)],
  ),
];

/// The value shown on the statistic labelled [label].
///
/// Read off the [Pill] rather than found by its text: the same digits appear
/// as ids and quantities elsewhere on screen, and a text finder would happily
/// match one of those instead.
String statistic(WidgetTester tester, String label) => tester
    .widget<Pill>(
      find.byWidgetPredicate(
        (widget) => widget is Pill && widget.label == label,
      ),
    )
    .value;

void main() {
  testWidgets(
    'shows a loading indicator and no orders while the first read is in flight',
    (tester) async {
      final gateway = MockOrdersGateway();

      final read = Completer<List<OrderEntity>>();
      when(gateway.getOrders).thenAnswer((_) => read.future);

      await pumpOrders(tester, gateway);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(Order), findsNothing);
    },
  );

  testWidgets('shows initial orders on the first read', (tester) async {
    final gateway = MockOrdersGateway();
    when(gateway.getOrders).thenAnswer((_) async => ordersMock);

    await pumpOrders(tester, gateway);
    await tester.pumpAndSettle();

    expect(find.text('idle'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // one card per order, each saying which it is and whose
    expect(find.byType(Order), findsNWidgets(3));
    expect(find.text('order-1'), findsOneWidget);
    expect(find.text('order-2'), findsOneWidget);
    expect(find.text('order-3'), findsOneWidget);
    expect(find.text('User user-a'), findsNWidgets(2));
    expect(find.text('User user-b'), findsOneWidget);

    // and how much each holds, without being opened
    expect(find.text('2 items'), findsOneWidget);
    expect(find.text('1 item'), findsNWidgets(2));

    // the same orders counted four ways
    expect(statistic(tester, 'users'), '2');
    expect(statistic(tester, 'orders'), '3');
    expect(statistic(tester, 'items'), '4');
    expect(statistic(tester, 'qty'), '14');
  });
}
