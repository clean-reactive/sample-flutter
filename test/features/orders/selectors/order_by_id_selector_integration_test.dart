import 'package:cleanreactive/features/orders/repositories/order_entities.dart';
import 'package:cleanreactive/features/orders/repositories/orders_repository.dart';
import 'package:cleanreactive/features/orders/repositories/orders_service/orders_service.dart';
import 'package:cleanreactive/features/orders/selectors/order_by_id_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../orders_factory.dart';
import '../repositories/mock_orders_gateway.dart';

/// The selector wired to the repository it reads through, with only the
/// gateway stood in for.
({ProviderContainer container, MockOrdersGateway gateway}) wired() {
  final gateway = MockOrdersGateway();
  final container = ProviderContainer.test(
    overrides: [ordersServiceProvider.overrideWithValue(gateway)],
  );
  return (container: container, gateway: gateway);
}

void serving(MockOrdersGateway gateway, List<OrderEntity> orders) =>
    when(gateway.getOrders).thenAnswer((_) async => orders);

/// The order the selector answers with for [orderId].
OrderEntity? orderOf(ProviderContainer container, String orderId) =>
    container.read(orderByIdSelector(OrderEntityId(orderId)));

void main() {
  group('orderByIdSelector', () {
    test('answers with the order held under that id', () async {
      final (:container, :gateway) = wired();
      serving(gateway, [
        makeOrder('order-1', userId: 'user-a'),
        makeOrder('order-2', userId: 'user-b'),
      ]);
      await container.read(ordersRepositoryProvider.future);

      expect(orderOf(container, 'order-2')?.userId, 'user-b');
    });

    test('answers with none before a read lands', () {
      final (:container, :gateway) = wired();
      serving(gateway, [makeOrder('order-1')]);

      container.read(ordersRepositoryProvider);

      expect(orderOf(container, 'order-1'), isNull);
    });

    test('answers with none when the order is not held', () async {
      final (:container, :gateway) = wired();
      serving(gateway, [makeOrder('order-1')]);
      await container.read(ordersRepositoryProvider.future);

      expect(orderOf(container, 'order-9'), isNull);
    });

    test('answers with none once the order is deleted', () async {
      final (:container, :gateway) = wired();
      serving(gateway, [makeOrder('order-1'), makeOrder('order-2')]);
      await container.read(ordersRepositoryProvider.future);

      // the resource as the delete leaves it, for the read that follows
      serving(gateway, [makeOrder('order-2')]);
      await container
          .read(ordersRepositoryProvider.notifier)
          .deleteOrder(const OrderEntityId('order-1'));

      expect(orderOf(container, 'order-1'), isNull);
      expect(orderOf(container, 'order-2'), isNotNull);
    });
  });
}
