import 'dart:async';

import 'package:cleanreactive/features/orders/repositories/order_entities.dart';
import 'package:cleanreactive/features/orders/repositories/orders_repository.dart';
import 'package:cleanreactive/features/orders/repositories/orders_service.dart';
import 'package:cleanreactive/features/orders/selectors/orders_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../orders_factory.dart';
import '../repositories/mock_orders_gateway.dart';

/// The selector wired to the repository it reads from, with only the gateway
/// stood in for.
///
/// What it answers is not arithmetic — it is what a read is doing: in flight,
/// landed, failed, failed after landing. None of those exist below the
/// repository, so the repository is real here and the resource is not.
({ProviderContainer container, MockOrdersGateway gateway}) wired() {
  final gateway = MockOrdersGateway();
  final container = ProviderContainer.test(
    overrides: [ordersGatewayProvider.overrideWithValue(gateway)],
    // Riverpod retries a failing provider on its own — ten times, 200ms
    // doubling to 6.4s. That is the repository's policy to have; a test about
    // what the selector holds while a read is failed cannot wait it out.
    retry: (_, _) => null,
  );
  return (container: container, gateway: gateway);
}

List<String> idsOf(List<OrderEntity> orders) => [
  for (final order in orders) order.id,
];

void main() {
  group('ordersSelector', () {
    test('holds no orders while the first read is in flight', () {
      final (:container, :gateway) = wired();
      when(gateway.getOrders).thenAnswer((_) async => [makeOrder('order-1')]);

      container.read(ordersProvider);

      expect(
        container.read(ordersSelector),
        isEmpty,
        reason: 'the units below render a frame before any read lands',
      );
    });

    test('holds the orders a read landed with', () async {
      final (:container, :gateway) = wired();
      when(
        gateway.getOrders,
      ).thenAnswer((_) async => [makeOrder('order-1'), makeOrder('order-2')]);

      await container.read(ordersProvider.future);

      expect(idsOf(container.read(ordersSelector)), ['order-1', 'order-2']);
    });

    test('holds no orders when the first read fails', () async {
      final (:container, :gateway) = wired();
      when(gateway.getOrders)
          .thenAnswer((_) async => throw Exception('no resource'));

      await expectLater(container.read(ordersProvider.future), throwsException);

      expect(
        container.read(ordersSelector),
        isEmpty,
        reason: 'a read that never landed has nothing to hold',
      );
    });

    test('holds what a later read replaces it with', () async {
      final (:container, :gateway) = wired();
      when(gateway.getOrders).thenAnswer((_) async => [makeOrder('order-1')]);
      await container.read(ordersProvider.future);

      when(gateway.getOrders).thenAnswer((_) async => [makeOrder('order-2')]);
      container.invalidate(ordersProvider);
      await container.read(ordersProvider.future);

      expect(
        [for (final order in container.read(ordersSelector)) order.id],
        ['order-2'],
      );
    });

    test('keeps the orders it had when a later read fails', () async {
      final (:container, :gateway) = wired();
      when(gateway.getOrders).thenAnswer((_) async => [makeOrder('order-1')]);
      await container.read(ordersProvider.future);

      when(gateway.getOrders)
          .thenAnswer((_) async => throw Exception('no resource'));
      container.invalidate(ordersProvider);
      await expectLater(container.read(ordersProvider.future), throwsException);

      expect(
        idsOf(container.read(ordersSelector)),
        ['order-1'],
        reason: 'a refetch that fails leaves the feature rendering what it had',
      );
    });

    test('keeps the orders it had while a later read is in flight', () async {
      final (:container, :gateway) = wired();
      when(gateway.getOrders).thenAnswer((_) async => [makeOrder('order-1')]);
      await container.read(ordersProvider.future);

      // held open, so there is a moment where a read is in flight over orders
      // that already landed — the state the feature calls fetching
      final refetch = Completer<List<OrderEntity>>();
      when(gateway.getOrders).thenAnswer((_) => refetch.future);
      container.invalidate(ordersProvider);
      container.read(ordersProvider);
      await container.pump();

      expect(idsOf(container.read(ordersSelector)), [
        'order-1',
      ], reason: 'a read in flight is not a reason to render nothing');

      refetch.complete([makeOrder('order-2')]);
      await container.read(ordersProvider.future);

      expect(idsOf(container.read(ordersSelector)), ['order-2']);
    });
  });
}
