import 'package:cleanreactive/features/orders/repositories/in_memory_orders_service.dart';
import 'package:cleanreactive/features/orders/repositories/order_entities.dart';
import 'package:cleanreactive/features/orders/repositories/orders_repository.dart';
import 'package:cleanreactive/features/orders/repositories/orders_service.dart';
import 'package:cleanreactive/features/orders/selectors/order_ids_selector.dart';
import 'package:cleanreactive/features/orders/use_cases/delete_order_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const ordersFixture = [
  OrderEntity(
    id: OrderEntityId('order-1'),
    userId: 'user-a',
    itemEntities: [
      ItemEntity(id: ItemEntityId('item-1'), productId: 'p1', quantity: 2),
      ItemEntity(id: ItemEntityId('item-2'), productId: 'p2', quantity: 5),
    ],
  ),
  OrderEntity(id: OrderEntityId('order-2'), userId: 'user-b', itemEntities: []),
];

void main() {
  group('DeleteOrderUseCase', () {
    test('removes the order, items and all', () async {
      final container = ProviderContainer.test(
        overrides: [
          ordersGatewayProvider.overrideWithValue(
            // its own growable copy: the service writes to what it is given
            InMemoryOrdersService([...ordersFixture], latency: Duration.zero),
          ),
        ],
      );
      await container.read(ordersProvider.future);

      await container
          .read(deleteOrderUseCase)
          .execute(const OrderEntityId('order-1'));
      await container.read(ordersProvider.future);

      expect(container.read(orderIdsSelector), ['order-2']);
    });
  });
}
