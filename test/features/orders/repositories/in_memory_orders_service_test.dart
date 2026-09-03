import 'package:cleanreactive/features/orders/repositories/in_memory_orders_service.dart';
import 'package:cleanreactive/features/orders/repositories/order_entities.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      final service = InMemoryOrdersService([
        ...seedFixture,
      ], latency: Duration.zero);

      expect(await service.getOrders(), seedFixture);
    });

    test('is seeded with orders where it is built', () async {
      final container = ProviderContainer.test();

      final service = container.read(inMemoryOrdersServiceProvider);

      expect(await service.getOrders(), isNotEmpty);
    });
  });
}
