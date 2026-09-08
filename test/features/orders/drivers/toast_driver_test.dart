import 'package:cleanreactive/features/orders/drivers/toast_driver.dart';
import 'package:cleanreactive/features/orders/repositories/orders_service/orders_service.dart';
import 'package:cleanreactive/features/orders/widgets/orders.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../orders_factory.dart';
import '../repositories/mock_orders_gateway.dart';

/// The driver beside the screen, with only the resource stood in for.
///
/// The screen is here because the driver renders nothing: something has to
/// read the orders for there to be a read to fail.
Future<void> pumpFeature(WidgetTester tester, MockOrdersGateway gateway) =>
    tester.pumpWidget(
      ProviderScope(
        overrides: [ordersServiceProvider.overrideWithValue(gateway)],
        child: const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                SingleChildScrollView(child: Orders()),
                OrdersToastDriver(),
              ],
            ),
          ),
        ),
      ),
    );

const message = 'could not read the orders';

void main() {
  group('OrdersToastDriver', () {
    testWidgets('announces a read that failed', (tester) async {
      final gateway = MockOrdersGateway();
      when(gateway.getOrders)
          .thenAnswer((_) async => throw Exception('no resource'));

      await pumpFeature(tester, gateway);
      await tester.pump();

      expect(find.widgetWithText(SnackBar, message), findsOneWidget);
    });

    testWidgets('announces nothing when the read lands', (tester) async {
      final gateway = MockOrdersGateway();
      when(gateway.getOrders).thenAnswer((_) async => [makeOrder('order-1')]);

      await pumpFeature(tester, gateway);
      await tester.pump();

      expect(
        find.byType(SnackBar),
        findsNothing,
        reason: 'a read that landed is nothing to announce',
      );
    });

    testWidgets('renders nothing of its own', (tester) async {
      final gateway = MockOrdersGateway();
      when(gateway.getOrders).thenAnswer((_) async => [makeOrder('order-1')]);

      await pumpFeature(tester, gateway);
      await tester.pump();

      expect(tester.getSize(find.byType(OrdersToastDriver)), Size.zero);
    });
  });
}
