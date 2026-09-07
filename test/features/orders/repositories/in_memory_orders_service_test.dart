import 'package:cleanreactive/features/orders/repositories/in_memory_orders_service.dart';
import 'package:cleanreactive/features/orders/repositories/order_entities.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../orders_factory.dart';

/// Two orders, the first holding two items — enough to show that a delete
/// takes what it was asked for and nothing next to it.
List<OrderEntity> makeSeed() => [
  makeOrder(
    'order-1',
    userId: 'user-a',
    items: [makeItem('item-1'), makeItem('item-2')],
  ),
  makeOrder('order-2', userId: 'user-b'),
];

/// A service holding a seed of its own.
///
/// Its own, because the service writes to the list it is given: a seed shared
/// between tests would carry one test's deletes into the next.
InMemoryOrdersService makeService() =>
    InMemoryOrdersService(makeSeed(), latency: Duration.zero);

/// The ids of [orders], in the order they were answered in.
///
/// Entities carry no `==`, so an expectation written against them compares by
/// identity and reports `Instance of 'OrderEntity'` when it fails. The ids are
/// what the cases here are about, and they read.
List<String> idsOf(List<OrderEntity> orders) => [
  for (final order in orders) order.id,
];

void main() {
  group('InMemoryOrdersService', () {
    test('serves the orders it holds', () async {
      final seed = makeSeed();
      final service = InMemoryOrdersService(seed, latency: Duration.zero);

      expect(await service.getOrders(), seed);
    });

    test('answers with a fresh list each read', () async {
      final service = makeService();

      final first = await service.getOrders();
      final second = await service.getOrders();

      expect(
        identical(first, second),
        isFalse,
        reason:
            'a real resource builds its answer per read, and the selectors '
            'that gate on the ids are written for one that does',
      );
    });

    test('does not answer before its latency has passed', () async {
      final service = InMemoryOrdersService(
        makeSeed(),
        latency: const Duration(milliseconds: 20),
      );
      var answered = false;

      final read = service.getOrders().then((_) => answered = true);
      await Future<void>.delayed(Duration.zero);

      expect(
        answered,
        isFalse,
        reason: 'a read that lands at once never shows the feature loading',
      );
      await read;
      expect(answered, isTrue);
    });

    test('is seeded with orders where it is built', () async {
      final container = ProviderContainer.test();

      final service = container.read(inMemoryOrdersServiceProvider);

      expect(await service.getOrders(), isNotEmpty);
    });

    group('deleting an order', () {
      test('removes it and leaves the rest', () async {
        final service = makeService();

        await service.deleteOrder(const OrderEntityId('order-1'));

        expect(idsOf(await service.getOrders()), ['order-2']);
      });

      test('refuses an order it does not hold', () async {
        final service = makeService();

        await expectLater(
          service.deleteOrder(const OrderEntityId('order-9')),
          throwsStateError,
        );
        expect(idsOf(await service.getOrders()), [
          'order-1',
          'order-2',
        ], reason: 'a refused delete leaves the orders as they were');
      });
    });

    group('deleting an item', () {
      test('removes it and keeps the order it belonged to', () async {
        final service = makeService();

        await service.deleteItem(
          const OrderEntityId('order-1'),
          const ItemEntityId('item-1'),
        );

        final order = (await service.getOrders()).first;
        expect(order.id, const OrderEntityId('order-1'));
        expect(
          order.userId,
          'user-a',
          reason: 'the order is rebuilt around the remaining items, not remade',
        );
        expect([for (final item in order.itemEntities) item.id], ['item-2']);
      });

      test('leaves the other orders alone', () async {
        final service = makeService();

        await service.deleteItem(
          const OrderEntityId('order-1'),
          const ItemEntityId('item-1'),
        );

        expect(idsOf(await service.getOrders()), ['order-1', 'order-2']);
      });

      test('refuses an order it does not hold', () async {
        final service = makeService();

        await expectLater(
          service.deleteItem(
            const OrderEntityId('order-9'),
            const ItemEntityId('item-1'),
          ),
          throwsStateError,
        );
      });
    });
  });
}
