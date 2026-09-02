import 'package:cleanreactive/features/orders/repositories/in_memory_orders_service.dart';
import 'package:cleanreactive/features/orders/repositories/order_entities.dart';
import 'package:flutter_test/flutter_test.dart';

const seedFixture = [
  OrderEntity(
    id: OrderEntityId('order-1'),
    userId: 'user-a',
    itemEntities: [
      ItemEntity(
        id: ItemEntityId('item-1'),
        productId: 'product-1',
        quantity: 2,
      ),
    ],
  ),
  OrderEntity(id: OrderEntityId('order-2'), userId: 'user-b', itemEntities: []),
];

void main() {
  group('InMemoryOrdersService', () {
    test('serves the orders it holds', () async {
      const service = InMemoryOrdersService(
        orders: seedFixture,
        latency: Duration.zero,
      );

      expect(await service.getOrders(), seedFixture);
    });

    test('holds orders unless it is given others', () async {
      const service = InMemoryOrdersService(latency: Duration.zero);

      expect(await service.getOrders(), isNotEmpty);
    });
  });
}
