import 'dart:async';

import 'package:cleanreactive/features/orders/repositories/order_entities.dart';
import 'package:cleanreactive/features/orders/repositories/orders_service.dart';
import 'package:cleanreactive/features/orders/widgets/order/order.dart';
import 'package:cleanreactive/features/orders/widgets/orders.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

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

void main() {
  testWidgets('a first read shows it is loading, and no orders', (
    tester,
  ) async {
    final gateway = MockOrdersGateway();

    final read = Completer<List<OrderEntity>>();
    when(gateway.getOrders).thenAnswer((_) => read.future);

    await pumpOrders(tester, gateway);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(Order), findsNothing);
  });
}
