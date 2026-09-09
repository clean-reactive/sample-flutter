import 'dart:async';

import 'package:cleanreactive/features/orders/repositories/order_entities.dart';
import 'package:cleanreactive/features/orders/repositories/orders_repository.dart';
import 'package:cleanreactive/features/orders/repositories/orders_service/orders_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../orders_factory.dart';
import 'mock_orders_gateway.dart';

/// The repository with only its resource stood in for.
///
/// The repository is the one unit that owns what a write does beyond the write
/// itself — that the orders it holds change the moment a delete is asked for,
/// that they go back when the write fails, that the resource has the last word
/// when it lands, and that the feature knows a write is running while it runs.
/// None of that is visible from the gateway, so the gateway is the double and
/// everything above it is absent.
///
/// The counter is listened to, not just read. Nothing else in this container
/// holds it, and a provider nothing holds does not survive between the write
/// that raises it and the assertion that reads it; in the application
/// `isOrdersMutatingSelector` is what watches it.
({ProviderContainer container, MockOrdersGateway gateway}) wired() {
  final gateway = MockOrdersGateway();
  final container = ProviderContainer.test(
    overrides: [ordersServiceProvider.overrideWithValue(gateway)],
    // Riverpod retries a failing provider on its own — ten times, 200ms
    // doubling to 6.4s. A test about what a failed read leaves behind cannot
    // wait that out.
    retry: (_, _) => null,
  );
  container.listen(ordersRepositoryWritesInFlightProvider, (_, _) {});
  return (container: container, gateway: gateway);
}

/// Has [gateway] serve [ids] as orders, freshly built on every read.
void serving(MockOrdersGateway gateway, List<String> ids) =>
    when(gateway.getOrders)
        .thenAnswer((_) async => [for (final id in ids) makeOrder(id)]);

/// Has [gateway] serve one order holding [itemIds], freshly built on every
/// read.
void servingItems(MockOrdersGateway gateway, List<String> itemIds) =>
    when(gateway.getOrders).thenAnswer(
      (_) async => [
        makeOrder('order-1', items: [for (final id in itemIds) makeItem(id)]),
      ],
    );

/// The orders the repository holds at this instant.
///
/// Read off the state rather than awaited: what an optimistic write changes is
/// what is held before anything lands, and awaiting would skip past it.
List<OrderEntity> held(ProviderContainer container) =>
    container.read(ordersRepositoryProvider).requireValue;

/// The ids of [orders], in the order they were answered in.
///
/// Entities carry no `==`, so an expectation written against them compares by
/// identity and reports `Instance of 'OrderEntity'` when it fails.
List<String> idsOf(List<OrderEntity> orders) => [
  for (final order in orders) order.id,
];

/// The ids of the items of [order], in the order they were answered in.
List<String> itemIdsOf(OrderEntity order) => [
  for (final item in order.itemEntities) item.id,
];

const orderId = OrderEntityId('order-1');
const itemId = ItemEntityId('item-1');

void main() {
  group('OrdersRepository', () {
    test('holds the orders the resource answered with', () async {
      final (:container, :gateway) = wired();
      serving(gateway, ['order-1', 'order-2']);

      final orders = await container.read(ordersRepositoryProvider.future);

      expect(idsOf(orders), ['order-1', 'order-2']);
    });

    test('fails when the read fails', () async {
      final (:container, :gateway) = wired();
      when(gateway.getOrders)
          .thenAnswer((_) async => throw Exception('no resource'));

      await expectLater(
        container.read(ordersRepositoryProvider.future),
        throwsException,
        reason: 'a read that did not land is not an empty list of orders',
      );
    });

    group('deleteOrder', () {
      test('asks the resource to delete that order', () async {
        final (:container, :gateway) = wired();
        serving(gateway, ['order-1', 'order-2']);
        await container.read(ordersRepositoryProvider.future);

        await container
            .read(ordersRepositoryProvider.notifier)
            .deleteOrder(orderId);

        verify(() => gateway.deleteOrder(orderId)).called(1);
        verifyNever(() => gateway.deleteItem(any(), any()));
      });

      test('drops the order before the write lands', () async {
        final (:container, :gateway) = wired();
        serving(gateway, ['order-1', 'order-2']);
        await container.read(ordersRepositoryProvider.future);

        // held open, so there is a moment where the delete has been asked for
        // and the resource has not answered — the moment the feature renders
        // as though it already had
        final deletion = Completer<void>();
        when(() => gateway.deleteOrder(any()))
            .thenAnswer((_) => deletion.future);
        final writing = container
            .read(ordersRepositoryProvider.notifier)
            .deleteOrder(orderId);

        expect(
          idsOf(held(container)),
          ['order-2'],
          reason:
              'the order is gone the moment it is asked for, not when the '
              'resource gets around to it',
        );

        deletion.complete();
        await writing;
      });

      test('reads again, so the resource has the last word', () async {
        final (:container, :gateway) = wired();
        serving(gateway, ['order-1', 'order-2']);
        await container.read(ordersRepositoryProvider.future);

        // an answer the dropped order alone would not produce: what the
        // repository ends up holding has to have come from the read
        serving(gateway, ['order-2', 'order-3']);
        await container
            .read(ordersRepositoryProvider.notifier)
            .deleteOrder(orderId);

        expect(idsOf(await container.read(ordersRepositoryProvider.future)), [
          'order-2',
          'order-3',
        ]);
      });

      test('puts the order back where it was when the write fails', () async {
        final (:container, :gateway) = wired();
        serving(gateway, ['order-1', 'order-2']);
        await container.read(ordersRepositoryProvider.future);

        final deletion = Completer<void>();
        when(() => gateway.deleteOrder(any()))
            .thenAnswer((_) => deletion.future);
        final writing = container
            .read(ordersRepositoryProvider.notifier)
            .deleteOrder(orderId);
        expect(idsOf(held(container)), ['order-2']);

        deletion.completeError(Exception('no resource'));
        await expectLater(writing, throwsException);

        expect(idsOf(held(container)), [
          'order-1',
          'order-2',
        ], reason: 'an order put back belongs where it was, not at the end');
      });

      test('does not read again when the write fails', () async {
        final (:container, :gateway) = wired();
        serving(gateway, ['order-1', 'order-2']);
        await container.read(ordersRepositoryProvider.future);

        when(() => gateway.deleteOrder(any()))
            .thenAnswer((_) async => throw Exception('no resource'));
        // what a read would answer, if one happened
        serving(gateway, ['order-9']);

        await expectLater(
          container
              .read(ordersRepositoryProvider.notifier)
              .deleteOrder(orderId),
          throwsException,
        );
        await container.pump();

        expect(idsOf(held(container)), [
          'order-1',
          'order-2',
        ], reason: 'a write that did not happen is nothing to read again for');
      });

      test('counts the write while it is in flight', () async {
        final (:container, :gateway) = wired();
        serving(gateway, ['order-1']);
        await container.read(ordersRepositoryProvider.future);

        expect(container.read(ordersRepositoryWritesInFlightProvider), 0);

        final deletion = Completer<void>();
        when(() => gateway.deleteOrder(any()))
            .thenAnswer((_) => deletion.future);
        final writing = container
            .read(ordersRepositoryProvider.notifier)
            .deleteOrder(orderId);

        expect(container.read(ordersRepositoryWritesInFlightProvider), 1);

        deletion.complete();
        await writing;

        expect(container.read(ordersRepositoryWritesInFlightProvider), 0);
      });

      test('stops counting the write when it fails', () async {
        final (:container, :gateway) = wired();
        serving(gateway, ['order-1']);
        await container.read(ordersRepositoryProvider.future);

        when(() => gateway.deleteOrder(any()))
            .thenAnswer((_) async => throw Exception('no resource'));

        await expectLater(
          container
              .read(ordersRepositoryProvider.notifier)
              .deleteOrder(orderId),
          throwsException,
        );

        expect(
          container.read(ordersRepositoryWritesInFlightProvider),
          0,
          reason: 'a write that failed is a write that is no longer running',
        );
      });

      test('keeps deleted orders gone while the deletes behind them are still '
          'in flight', () async {
        final (:container, :gateway) = wired();

        // the resource as the writes leave it: a delete lands on it when the
        // gateway is let answer, and every read from then on answers with
        // what has landed so far
        final resource = ['order-1', 'order-2', 'order-3', 'order-4'];
        when(
          gateway.getOrders,
        ).thenAnswer((_) async => [for (final id in resource) makeOrder(id)]);

        // held open one per order, so all three deletes can be asked for
        // before any of them is answered — the user clicking faster than the
        // resource replies
        final deletions = <String, Completer<void>>{};
        when(() => gateway.deleteOrder(any())).thenAnswer((invocation) {
          final id = invocation.positionalArguments.single as String;
          return (deletions[id] = Completer<void>()).future;
        });

        await container.read(ordersRepositoryProvider.future);
        final repository = container.read(ordersRepositoryProvider.notifier);

        final writing = [
          for (final id in ['order-1', 'order-2', 'order-3'])
            repository.deleteOrder(OrderEntityId(id)),
        ];
        expect(idsOf(held(container)), ['order-4']);

        // every answer the repository settles on from here, in the order it
        // settled on them. Listened rather than read, so a read the repository
        // starts on its own is recorded too, and only where the read is over:
        // a refresh in flight re-answers with the orders before it, which are
        // already on the list.
        final shown = <List<String>>[];
        container.listen(ordersRepositoryProvider, (_, next) {
          if (next case AsyncData(:final value, isLoading: false)) {
            shown.add(idsOf(value));
          }
        }, fireImmediately: true);

        // one at a time, each let land and be read after before the next
        // one is: the reads are then as far apart as they get, and what one
        // of them answers cannot be excused as the next one not having
        // started yet
        for (final id in ['order-1', 'order-2', 'order-3']) {
          resource.remove(id);
          deletions[id]!.complete();
          await container.pump();
          await container.pump();
        }
        await Future.wait(writing);
        await container.pump();

        expect(
          shown,
          everyElement(equals(['order-4'])),
          reason:
              'an order the user has deleted does not come back because a '
              'read that another delete started answered with what the '
              'resource held before this one landed',
        );
      });
    });

    group('deleteItem', () {
      test('asks the resource to delete that item of that order', () async {
        final (:container, :gateway) = wired();
        servingItems(gateway, ['item-1', 'item-2']);
        await container.read(ordersRepositoryProvider.future);

        await container
            .read(ordersRepositoryProvider.notifier)
            .deleteItem(orderId, itemId);

        verify(() => gateway.deleteItem(orderId, itemId)).called(1);
        verifyNever(() => gateway.deleteOrder(any()));
      });

      test(
        'drops the item, and keeps its order, before the write lands',
        () async {
          final (:container, :gateway) = wired();
          servingItems(gateway, ['item-1', 'item-2']);
          await container.read(ordersRepositoryProvider.future);

          final deletion = Completer<void>();
          when(() => gateway.deleteItem(any(), any()))
              .thenAnswer((_) => deletion.future);
          final writing = container
              .read(ordersRepositoryProvider.notifier)
              .deleteItem(orderId, itemId);

          expect(idsOf(held(container)), [
            'order-1',
          ], reason: 'the order stays');
          expect(itemIdsOf(held(container).single), ['item-2']);

          deletion.complete();
          await writing;
        },
      );

      test('reads again, so the resource has the last word', () async {
        final (:container, :gateway) = wired();
        servingItems(gateway, ['item-1', 'item-2']);
        await container.read(ordersRepositoryProvider.future);

        // an answer the dropped item alone would not produce
        servingItems(gateway, ['item-2', 'item-3']);
        await container
            .read(ordersRepositoryProvider.notifier)
            .deleteItem(orderId, itemId);

        final orders = await container.read(ordersRepositoryProvider.future);

        expect(idsOf(orders), ['order-1']);
        expect(itemIdsOf(orders.single), ['item-2', 'item-3']);
      });

      test('puts the item back where it was when the write fails', () async {
        final (:container, :gateway) = wired();
        servingItems(gateway, ['item-1', 'item-2']);
        await container.read(ordersRepositoryProvider.future);

        final deletion = Completer<void>();
        when(() => gateway.deleteItem(any(), any()))
            .thenAnswer((_) => deletion.future);
        final writing = container
            .read(ordersRepositoryProvider.notifier)
            .deleteItem(orderId, itemId);
        expect(itemIdsOf(held(container).single), ['item-2']);

        deletion.completeError(Exception('no resource'));
        await expectLater(writing, throwsException);

        expect(itemIdsOf(held(container).single), [
          'item-1',
          'item-2',
        ], reason: 'an item put back belongs where it was, not at the end');
      });

      test('does not read again when the write fails', () async {
        final (:container, :gateway) = wired();
        servingItems(gateway, ['item-1', 'item-2']);
        await container.read(ordersRepositoryProvider.future);

        when(() => gateway.deleteItem(any(), any()))
            .thenAnswer((_) async => throw Exception('no resource'));
        // what a read would answer, if one happened
        servingItems(gateway, ['item-9']);

        await expectLater(
          container
              .read(ordersRepositoryProvider.notifier)
              .deleteItem(orderId, itemId),
          throwsException,
        );
        await container.pump();

        expect(itemIdsOf(held(container).single), ['item-1', 'item-2']);
      });

      test('counts the write while it is in flight', () async {
        final (:container, :gateway) = wired();
        servingItems(gateway, ['item-1', 'item-2']);
        await container.read(ordersRepositoryProvider.future);

        final deletion = Completer<void>();
        when(() => gateway.deleteItem(any(), any()))
            .thenAnswer((_) => deletion.future);
        final writing = container
            .read(ordersRepositoryProvider.notifier)
            .deleteItem(orderId, itemId);

        expect(container.read(ordersRepositoryWritesInFlightProvider), 1);

        deletion.complete();
        await writing;

        expect(container.read(ordersRepositoryWritesInFlightProvider), 0);
      });

      test('stops counting the write when it fails', () async {
        final (:container, :gateway) = wired();
        servingItems(gateway, ['item-1', 'item-2']);
        await container.read(ordersRepositoryProvider.future);

        when(() => gateway.deleteItem(any(), any()))
            .thenAnswer((_) async => throw Exception('no resource'));

        await expectLater(
          container
              .read(ordersRepositoryProvider.notifier)
              .deleteItem(orderId, itemId),
          throwsException,
        );

        expect(container.read(ordersRepositoryWritesInFlightProvider), 0);
      });
    });

    group('dropOrders', () {
      test('drops the orders held', () async {
        final (:container, :gateway) = wired();
        serving(gateway, ['order-1', 'order-2']);
        await container.read(ordersRepositoryProvider.future);

        container.read(ordersRepositoryProvider.notifier).dropOrders();

        expect(idsOf(held(container)), isEmpty);
      });

      test('asks the resource for nothing', () async {
        final (:container, :gateway) = wired();
        serving(gateway, ['order-1', 'order-2']);
        await container.read(ordersRepositoryProvider.future);

        container.read(ordersRepositoryProvider.notifier).dropOrders();

        verify(gateway.getOrders).called(1);
        verifyNever(() => gateway.deleteOrder(any()));
        verifyNever(() => gateway.deleteItem(any(), any()));
      });

      test('holds nothing while the read that follows is in flight', () async {
        final (:container, :gateway) = wired();
        serving(gateway, ['order-1', 'order-2']);
        await container.read(ordersRepositoryProvider.future);

        container.read(ordersRepositoryProvider.notifier).dropOrders();

        // held open, so there is a moment where the read has started and the
        // resource has not answered — the moment a rebuild would otherwise
        // stand the dropped orders back up
        final read = Completer<List<OrderEntity>>();
        when(gateway.getOrders).thenAnswer((_) => read.future);
        container.invalidate(ordersRepositoryProvider);
        container.read(ordersRepositoryProvider);
        await container.pump();

        expect(
          idsOf(held(container)),
          isEmpty,
          reason:
              'a read keeps what is held when it starts, and by then nothing '
              'was',
        );

        read.complete([]);
        await container.pump();
      });
    });
  });
}
