import 'dart:async';

import 'package:cleanreactive/features/orders/repositories/order_entities.dart';
import 'package:cleanreactive/features/orders/repositories/orders_repository.dart';
import 'package:cleanreactive/features/orders/repositories/orders_service/orders_service.dart';
import 'package:cleanreactive/features/orders/selectors/order_ids_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../orders_factory.dart';
import '../repositories/mock_orders_gateway.dart';

/// The selector wired to the repository it reads through, with only the
/// gateway stood in for.
///
/// Every read builds its orders afresh, the way a real resource answers, so
/// two reads of the same ids arrive as equal contents in different objects —
/// which is the whole reason this selector carries an [IList].
({ProviderContainer container, MockOrdersGateway gateway}) wired() {
  final gateway = MockOrdersGateway();
  final container = ProviderContainer.test(
    overrides: [ordersServiceProvider.overrideWithValue(gateway)],
    // Riverpod retries a failing provider on its own — ten times, 200ms
    // doubling to 6.4s. A test about what the selector reports while a read is
    // failed cannot wait that out.
    retry: (_, _) => null,
  );
  return (container: container, gateway: gateway);
}

/// Has [gateway] serve [ids] as orders, freshly built on every read.
void serving(MockOrdersGateway gateway, List<String> ids) =>
    when(gateway.getOrders)
        .thenAnswer((_) async => [for (final id in ids) makeOrder(id)]);

void main() {
  group('orderIdsSelector', () {
    test('reports no ids before a read lands', () {
      final (:container, :gateway) = wired();
      serving(gateway, ['order-1']);

      container.read(ordersRepositoryProvider);

      expect(container.read(orderIdsSelector), isEmpty);
    });

    test('reports the ids of the orders read, in the order read', () async {
      final (:container, :gateway) = wired();
      serving(gateway, ['order-2', 'order-1']);

      await container.read(ordersRepositoryProvider.future);

      expect(container.read(orderIdsSelector), ['order-2', 'order-1']);
    });

    test('reports no ids when the first read fails', () async {
      final (:container, :gateway) = wired();
      when(gateway.getOrders)
          .thenAnswer((_) async => throw Exception('no resource'));

      await expectLater(
        container.read(ordersRepositoryProvider.future),
        throwsException,
      );

      expect(container.read(orderIdsSelector), isEmpty);
    });

    test('keeps the ids while a later read is in flight', () async {
      final (:container, :gateway) = wired();
      serving(gateway, ['order-1']);
      await container.read(ordersRepositoryProvider.future);

      final refetch = Completer<List<OrderEntity>>();
      when(gateway.getOrders).thenAnswer((_) => refetch.future);
      container.invalidate(ordersRepositoryProvider);
      container.read(ordersRepositoryProvider);
      await container.pump();

      expect(container.read(orderIdsSelector), [
        'order-1',
      ], reason: 'a read in flight is not a reason to render nothing');

      refetch.complete([makeOrder('order-2')]);
      await container.read(ordersRepositoryProvider.future);

      expect(container.read(orderIdsSelector), ['order-2']);
    });

    test('keeps the ids when a later read fails', () async {
      final (:container, :gateway) = wired();
      serving(gateway, ['order-1']);
      await container.read(ordersRepositoryProvider.future);

      when(gateway.getOrders)
          .thenAnswer((_) async => throw Exception('no resource'));
      container.invalidate(ordersRepositoryProvider);
      await expectLater(
        container.read(ordersRepositoryProvider.future),
        throwsException,
      );

      expect(container.read(orderIdsSelector), ['order-1']);
    });

    test('announces nothing when a read returns the same ids', () async {
      final (:container, :gateway) = wired();
      serving(gateway, ['order-1', 'order-2']);
      var announcements = 0;
      container.listen(orderIdsSelector, (_, _) => announcements++);

      await container.read(ordersRepositoryProvider.future);
      await container.pump();
      final afterLoad = announcements;

      container.invalidate(ordersRepositoryProvider);
      await container.read(ordersRepositoryProvider.future);
      await container.pump();

      expect(
        announcements,
        afterLoad,
        reason: 'the orders are new objects, the ids they carry are not new',
      );
    });

    test('announces the new ids when they change', () async {
      final (:container, :gateway) = wired();
      serving(gateway, ['order-1', 'order-2']);
      var announcements = 0;
      container.listen(orderIdsSelector, (_, _) => announcements++);

      await container.read(ordersRepositoryProvider.future);
      await container.pump();
      final afterLoad = announcements;

      serving(gateway, ['order-1', 'order-3']);
      container.invalidate(ordersRepositoryProvider);
      await container.read(ordersRepositoryProvider.future);
      await container.pump();

      expect(announcements, greaterThan(afterLoad));
      expect(container.read(orderIdsSelector), ['order-1', 'order-3']);
    });
  });
}
