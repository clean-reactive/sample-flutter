import 'package:cleanreactive/features/orders/repositories/in_memory_orders_service.dart';
import 'package:cleanreactive/features/orders/repositories/order_entities.dart';
import 'package:cleanreactive/features/orders/repositories/orders_repository.dart';
import 'package:cleanreactive/features/orders/repositories/orders_service.dart';
import 'package:cleanreactive/features/orders/selectors/order_ids_selector.dart';
import 'package:cleanreactive/features/orders/selectors/order_item_ids_selector.dart';
import 'package:cleanreactive/features/orders/use_cases/delete_order_item_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// One order of two items, one order of one — enough to tell the two outcomes
/// apart.
const ordersFixture = [
  OrderEntity(
    id: OrderEntityId('order-1'),
    userId: 'user-a',
    itemEntities: [
      ItemEntity(id: ItemEntityId('item-1'), productId: 'p1', quantity: 2),
      ItemEntity(id: ItemEntityId('item-2'), productId: 'p2', quantity: 5),
    ],
  ),
  OrderEntity(
    id: OrderEntityId('order-2'),
    userId: 'user-b',
    itemEntities: [
      ItemEntity(id: ItemEntityId('item-3'), productId: 'p3', quantity: 3),
    ],
  ),
];

Future<ProviderContainer> containerWithOrdersRead() async {
  final container = ProviderContainer.test(
    overrides: [
      ordersGatewayProvider.overrideWithValue(
        // its own growable copy: the service writes to what it is given
        InMemoryOrdersService([...ordersFixture], latency: Duration.zero),
      ),
    ],
  );
  await container.read(ordersProvider.future);
  return container;
}

void main() {
  group('DeleteOrderItemUseCase', () {
    test('removes the item, leaving the order it belonged to', () async {
      final container = await containerWithOrdersRead();

      await container.read(deleteOrderItemUseCase).execute((
        orderId: const OrderEntityId('order-1'),
        itemId: const ItemEntityId('item-1'),
      ));
      await container.read(ordersProvider.future);

      expect(container.read(orderIdsSelector), ['order-1', 'order-2']);
      expect(
        container.read(orderItemIdsSelector(const OrderEntityId('order-1'))),
        ['item-2'],
      );
    });

    test('removes the order when the item was its last', () async {
      final container = await containerWithOrdersRead();

      await container.read(deleteOrderItemUseCase).execute((
        orderId: const OrderEntityId('order-2'),
        itemId: const ItemEntityId('item-3'),
      ));
      await container.read(ordersProvider.future);

      expect(container.read(orderIdsSelector), ['order-1']);
    });
  });
}
