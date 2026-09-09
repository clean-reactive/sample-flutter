import 'package:cleanreactive/features/orders/repositories/order_entities.dart';
import 'package:cleanreactive/features/orders/repositories/orders_repository.dart';
import 'package:cleanreactive/features/orders/repositories/orders_service/orders_service.dart';
import 'package:cleanreactive/features/orders/selectors/item_by_id_selector.dart';
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

/// The item the selector answers with for [orderId] and [itemId].
ItemEntity? itemOf(
  ProviderContainer container,
  String orderId,
  String itemId,
) => container.read(
  itemByIdSelector((OrderEntityId(orderId), ItemEntityId(itemId))),
);

void main() {
  group('itemByIdSelector', () {
    test('answers with the item the order holds under that id', () async {
      final (:container, :gateway) = wired();
      serving(gateway, [
        makeOrder(
          'order-1',
          items: [
            makeItem('item-1', productId: 'lamp'),
            makeItem('item-2', productId: 'chair'),
          ],
        ),
      ]);
      await container.read(ordersRepositoryProvider.future);

      expect(itemOf(container, 'order-1', 'item-2')?.productId, 'chair');
    });

    test('answers with none before a read lands', () async {
      final (:container, :gateway) = wired();
      serving(gateway, [
        makeOrder('order-1', items: [makeItem('item-1')]),
      ]);

      container.read(ordersRepositoryProvider);

      expect(itemOf(container, 'order-1', 'item-1'), isNull);
    });

    test('answers with none when the order is not held', () async {
      final (:container, :gateway) = wired();
      serving(gateway, [
        makeOrder('order-1', items: [makeItem('item-1')]),
      ]);
      await container.read(ordersRepositoryProvider.future);

      expect(itemOf(container, 'order-2', 'item-1'), isNull);
    });

    test('answers with none when the order holds no such item', () async {
      final (:container, :gateway) = wired();
      serving(gateway, [
        makeOrder('order-1', items: [makeItem('item-1')]),
      ]);
      await container.read(ordersRepositoryProvider.future);

      expect(itemOf(container, 'order-1', 'item-9'), isNull);
    });

    test('does not answer with an item another order holds', () async {
      final (:container, :gateway) = wired();
      serving(gateway, [
        makeOrder('order-1'),
        makeOrder('order-2', items: [makeItem('item-1')]),
      ]);
      await container.read(ordersRepositoryProvider.future);

      expect(
        itemOf(container, 'order-1', 'item-1'),
        isNull,
        reason: 'an item id is meaningful only within the order holding it',
      );
    });
  });
}
