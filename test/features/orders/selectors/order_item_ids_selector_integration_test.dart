import 'package:cleanreactive/features/orders/repositories/order_entities.dart';
import 'package:cleanreactive/features/orders/repositories/orders_repository.dart';
import 'package:cleanreactive/features/orders/repositories/orders_service/orders_service.dart';
import 'package:cleanreactive/features/orders/selectors/order_item_ids_selector.dart';
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

/// Has [gateway] answer with orders built afresh on every read, so two reads of
/// the same items arrive as equal contents in different objects — which is the
/// reason this selector carries an [IList].
void serving(MockOrdersGateway gateway, List<OrderEntity> Function() orders) =>
    when(gateway.getOrders).thenAnswer((_) async => orders());

void main() {
  group('orderItemIdsSelector', () {
    test('reports no ids for an order that is not held', () async {
      final (:container, :gateway) = wired();
      serving(gateway, () => [makeOrder('order-1')]);
      await container.read(ordersRepositoryProvider.future);

      expect(
        container.read(orderItemIdsSelector(OrderEntityId('order-2'))),
        isEmpty,
      );
    });

    test('reports no ids for an order that holds no items', () async {
      final (:container, :gateway) = wired();
      serving(gateway, () => [makeOrder('order-1')]);
      await container.read(ordersRepositoryProvider.future);

      expect(
        container.read(orderItemIdsSelector(OrderEntityId('order-1'))),
        isEmpty,
      );
    });

    test('reports the ids of the items held, in the order read', () async {
      final (:container, :gateway) = wired();
      serving(
        gateway,
        () => [
          makeOrder('order-1', items: [makeItem('item-2'), makeItem('item-1')]),
        ],
      );
      await container.read(ordersRepositoryProvider.future);

      expect(container.read(orderItemIdsSelector(OrderEntityId('order-1'))), [
        'item-2',
        'item-1',
      ]);
    });

    test('reports only the items of the order asked for', () async {
      final (:container, :gateway) = wired();
      serving(
        gateway,
        () => [
          makeOrder('order-1', items: [makeItem('item-1')]),
          makeOrder('order-2', items: [makeItem('item-2'), makeItem('item-3')]),
        ],
      );
      await container.read(ordersRepositoryProvider.future);

      expect(container.read(orderItemIdsSelector(OrderEntityId('order-2'))), [
        'item-2',
        'item-3',
      ]);
    });

    test('announces nothing when a read returns the same items', () async {
      final (:container, :gateway) = wired();
      serving(
        gateway,
        () => [
          makeOrder('order-1', items: [makeItem('item-1')]),
        ],
      );
      var announcements = 0;
      container.listen(
        orderItemIdsSelector(OrderEntityId('order-1')),
        (_, _) => announcements++,
      );

      await container.read(ordersRepositoryProvider.future);
      await container.pump();
      final afterLoad = announcements;

      container.invalidate(ordersRepositoryProvider);
      await container.read(ordersRepositoryProvider.future);
      await container.pump();

      expect(
        announcements,
        afterLoad,
        reason: 'the items are new objects, the ids they carry are not new',
      );
    });

    test('announces the new ids when the items change', () async {
      final (:container, :gateway) = wired();
      serving(
        gateway,
        () => [
          makeOrder('order-1', items: [makeItem('item-1')]),
        ],
      );
      var announcements = 0;
      container.listen(
        orderItemIdsSelector(OrderEntityId('order-1')),
        (_, _) => announcements++,
      );

      await container.read(ordersRepositoryProvider.future);
      await container.pump();
      final afterLoad = announcements;

      serving(
        gateway,
        () => [
          makeOrder('order-1', items: [makeItem('item-1'), makeItem('item-4')]),
        ],
      );
      container.invalidate(ordersRepositoryProvider);
      await container.read(ordersRepositoryProvider.future);
      await container.pump();

      expect(announcements, greaterThan(afterLoad));
      expect(container.read(orderItemIdsSelector(OrderEntityId('order-1'))), [
        'item-1',
        'item-4',
      ]);
    });
  });
}
