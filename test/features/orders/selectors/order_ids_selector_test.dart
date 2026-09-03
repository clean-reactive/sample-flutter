import 'package:cleanreactive/features/orders/repositories/order_entities.dart';
import 'package:cleanreactive/features/orders/repositories/orders_gateway.dart';
import 'package:cleanreactive/features/orders/repositories/orders_repository.dart';
import 'package:cleanreactive/features/orders/repositories/orders_service.dart';
import 'package:cleanreactive/features/orders/selectors/order_ids_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Serves the ids it is scripted with, always as a freshly built list — the way
/// a real resource answers, and the case the selector exists for.
class ScriptedGateway implements OrdersGateway {
  ScriptedGateway(this.reads);

  final List<List<String>> reads;
  var _read = 0;

  @override
  Future<List<OrderEntity>> getOrders() async {
    final ids = reads[_read < reads.length ? _read : reads.length - 1];
    _read++;
    return [
      for (final id in ids)
        OrderEntity(
          id: OrderEntityId(id),
          userId: 'user-a',
          itemEntities: const [],
        ),
    ];
  }

  // The selectors under test only read. Writing through this fake would say
  // nothing about them, so it refuses rather than pretending.
  @override
  Future<void> deleteOrder(OrderEntityId orderId) =>
      throw UnsupportedError('this fake only reads');

  @override
  Future<void> deleteItem(OrderEntityId orderId, ItemEntityId itemId) =>
      throw UnsupportedError('this fake only reads');
}

ProviderContainer containerServing(List<List<String>> reads) =>
    ProviderContainer.test(
      overrides: [
        ordersGatewayProvider.overrideWithValue(ScriptedGateway(reads)),
      ],
    );

void main() {
  group('orderIdsSelector', () {
    test('reports no ids before a read', () {
      final container = containerServing([[]]);

      expect(container.read(orderIdsSelector), isEmpty);
    });

    test('reports the ids of the orders read', () async {
      final container = containerServing([
        ['order-1', 'order-2'],
      ]);

      await container.read(ordersProvider.future);

      expect(container.read(orderIdsSelector), ['order-1', 'order-2']);
    });

    test('announces nothing when a read returns the same ids', () async {
      final container = containerServing([
        ['order-1', 'order-2'],
        ['order-1', 'order-2'],
      ]);
      var announcements = 0;
      container.listen(orderIdsSelector, (_, _) => announcements++);

      await container.read(ordersProvider.future);
      await Future<void>.delayed(Duration.zero);
      final afterLoad = announcements;

      container.invalidate(ordersProvider);
      await container.read(ordersProvider.future);
      await Future<void>.delayed(Duration.zero);

      expect(announcements, afterLoad);
    });

    test('announces the new ids when they change', () async {
      final container = containerServing([
        ['order-1', 'order-2'],
        ['order-1', 'order-3'],
      ]);
      var announcements = 0;
      container.listen(orderIdsSelector, (_, _) => announcements++);

      await container.read(ordersProvider.future);
      await Future<void>.delayed(Duration.zero);
      final afterLoad = announcements;

      container.invalidate(ordersProvider);
      await container.read(ordersProvider.future);
      await Future<void>.delayed(Duration.zero);

      expect(announcements, greaterThan(afterLoad));
      expect(container.read(orderIdsSelector), ['order-1', 'order-3']);
    });
  });
}
