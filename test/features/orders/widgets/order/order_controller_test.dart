import 'package:cleanreactive/features/orders/repositories/order_entities.dart';
import 'package:cleanreactive/features/orders/repositories/orders_repository.dart';
import 'package:cleanreactive/features/orders/repositories/orders_service/orders_service.dart';
import 'package:cleanreactive/features/orders/widgets/order/order.dart';
import 'package:cleanreactive/features/orders/widgets/order/order_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../orders_factory.dart';
import '../../repositories/mock_orders_gateway.dart';

const orderId = OrderEntityId('order-1');

/// One order on screen, with only the resource stood in for.
///
/// The container is the test's own, so it can say which units are alive while
/// the widget is on screen and after it is gone.
Future<ProviderContainer> pumpOrder(
  WidgetTester tester,
  MockOrdersGateway gateway,
) async {
  final container = ProviderContainer.test(
    overrides: [ordersServiceProvider.overrideWithValue(gateway)],
  );
  await container.read(ordersRepositoryProvider.future);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        home: Scaffold(body: Order(orderId: orderId)),
      ),
    ),
  );
  return container;
}

void main() {
  group('orderController', () {
    testWidgets('lives as long as the order on screen, across its rebuilds', (
      tester,
    ) async {
      final gateway = MockOrdersGateway();
      when(gateway.getOrders)
          .thenAnswer((_) async => [makeOrder('order-1', userId: 'user-a')]);
      final container = await pumpOrder(tester, gateway);

      expect(container.exists(orderController(orderId)), isTrue);
      final controller = container.read(orderController(orderId));

      // a read the presenter shows differently, so the order rebuilds
      when(gateway.getOrders)
          .thenAnswer((_) async => [makeOrder('order-1', userId: 'user-b')]);
      container.invalidate(ordersRepositoryProvider);
      await tester.pumpAndSettle();
      expect(find.text('User user-b'), findsOneWidget);

      expect(
        identical(container.read(orderController(orderId)), controller),
        isTrue,
        reason: 'a rebuild is not a reason to make the controller again',
      );
    });

    testWidgets('goes with the order when it leaves the screen', (
      tester,
    ) async {
      final gateway = MockOrdersGateway();
      when(gateway.getOrders).thenAnswer((_) async => [makeOrder('order-1')]);
      final container = await pumpOrder(tester, gateway);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: Scaffold()),
        ),
      );
      await tester.pump();

      expect(container.exists(orderController(orderId)), isFalse);
    });
  });
}
