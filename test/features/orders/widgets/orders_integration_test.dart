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

/// The delete button on the card standing for [orderId].
///
/// Found through the card rather than by its text: every order on screen offers
/// the same button, and a text finder would match all of them.
Finder deleteOrderButton(String orderId) => find.descendant(
  of: find.byWidgetPredicate(
    (widget) => widget is Order && widget.orderId == orderId,
  ),
  matching: find.widgetWithText(OutlinedButton, 'Delete Order'),
);

/// The orders on screen, in the order they are laid out.
///
/// Counting the cards would say how many survived a delete; this says which,
/// and where — an order put back belongs where it was, not at the end.
List<String> ordersOnScreen(WidgetTester tester) => tester
    .widgetList<Order>(find.byType(Order))
    .map((order) => order.orderId)
    .toList();

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

  testWidgets('takes a deleted order off the screen before the write lands', (
    tester,
  ) async {
    final gateway = MockOrdersGateway();

    // What the resource answers with, and what it answers with once the delete
    // has landed. The read after a write is the resource agreeing with the
    // screen, not what puts the order there — so it must not be the thing that
    // removes it either.
    var held = ordersMock;
    when(gateway.getOrders).thenAnswer((_) async => held);

    final delete = Completer<void>();
    when(() => gateway.deleteOrder(const OrderEntityId('order-2')))
        .thenAnswer((_) => delete.future);

    await pumpOrders(tester, gateway);
    await tester.pumpAndSettle();

    await tester.ensureVisible(deleteOrderButton('order-2'));
    await tester.tap(deleteOrderButton('order-2'));
    await tester.pump();

    // the order is off the screen while its delete is still in flight
    expect(delete.isCompleted, isFalse);
    expect(find.text('mutating'), findsOneWidget);
    expect(ordersOnScreen(tester), ['order-1', 'order-3']);

    // and every statistic counts as though it were already gone: order-2 was
    // user-b's only order, and carried the one item of quantity three
    expect(statistic(tester, 'users'), '1');
    expect(statistic(tester, 'orders'), '2');
    expect(statistic(tester, 'items'), '3');
    expect(statistic(tester, 'qty'), '11');

    // when the write lands, the read that follows agrees with what is shown —
    // nothing on screen moves
    held = ordersMock
        .where((order) => order.id != const OrderEntityId('order-2'))
        .toList();
    delete.complete();
    await tester.pumpAndSettle();

    expect(find.text('idle'), findsOneWidget);
    expect(ordersOnScreen(tester), ['order-1', 'order-3']);
    expect(statistic(tester, 'orders'), '2');
  });

  testWidgets('puts a deleted order back when the write fails', (tester) async {
    final gateway = MockOrdersGateway();

    // The resource still holds all three throughout: the write failed, so
    // nothing was ever removed there. What the screen shows in the meantime is
    // the feature's own doing, and taking it back is too.
    when(gateway.getOrders).thenAnswer((_) async => ordersMock);

    final delete = Completer<void>();
    when(() => gateway.deleteOrder(const OrderEntityId('order-2')))
        .thenAnswer((_) => delete.future);

    await pumpOrders(tester, gateway);
    await tester.pumpAndSettle();

    await tester.ensureVisible(deleteOrderButton('order-2'));
    await tester.tap(deleteOrderButton('order-2'));
    await tester.pump();

    // taken away first — a restore only says something if something went
    expect(ordersOnScreen(tester), ['order-1', 'order-3']);

    delete.completeError(Exception('the resource refused the delete'));
    await tester.pumpAndSettle();

    // back where it was, between the two that never moved
    expect(ordersOnScreen(tester), ['order-1', 'order-2', 'order-3']);
    expect(find.text('User user-b'), findsOneWidget);

    // and counted again, every statistic as it was before the press
    expect(statistic(tester, 'users'), '2');
    expect(statistic(tester, 'orders'), '3');
    expect(statistic(tester, 'items'), '4');
    expect(statistic(tester, 'qty'), '14');

    // nothing is in flight any more, and the order can be deleted again
    expect(find.text('idle'), findsOneWidget);
    expect(
      tester.widget<OutlinedButton>(deleteOrderButton('order-2')).onPressed,
      isNotNull,
    );
  });
}
