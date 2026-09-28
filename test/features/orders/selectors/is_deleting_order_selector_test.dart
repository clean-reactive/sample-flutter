import 'dart:async';

import 'package:cleanreactive/features/orders/repositories/order_entities.dart';
import 'package:cleanreactive/features/orders/repositories/orders_repository.dart';
import 'package:cleanreactive/features/orders/selectors/is_deleting_order_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final orderId = OrderEntityId('order-1');
final siblingOrderId = OrderEntityId('order-2');
final itemId = ItemEntityId('item-1');

/// Whether the selector reports a delete of [order] as in flight.
bool isDeleting(ProviderContainer container, OrderEntityId order) =>
    container.read(isDeletingOrderSelector(order));

void main() {
  group('isDeletingOrderSelector', () {
    test('reports nothing in flight when no delete has started', () {
      final container = ProviderContainer.test();

      expect(isDeleting(container, orderId), isFalse);
    });

    test('reports a delete of the order as in flight', () async {
      final container = ProviderContainer.test();
      final pending = Completer<void>();

      unawaited(
        deleteOrderMutation(orderId).run(container, (_) => pending.future),
      );
      await container.pump();

      expect(isDeleting(container, orderId), isTrue);
    });

    test('reports nothing in flight once the delete lands', () async {
      final container = ProviderContainer.test();
      final pending = Completer<void>();

      final run = deleteOrderMutation(orderId)
          .run(container, (_) => pending.future);
      await container.pump();
      pending.complete();
      await run;
      await container.pump();

      expect(isDeleting(container, orderId), isFalse);
    });

    test('reports nothing in flight for an order not being deleted', () async {
      final container = ProviderContainer.test();
      final pending = Completer<void>();

      unawaited(
        deleteOrderMutation(orderId).run(container, (_) => pending.future),
      );
      await container.pump();

      expect(isDeleting(container, siblingOrderId), isFalse);
    });

    test('reports nothing in flight while only an item is deleted', () async {
      final container = ProviderContainer.test();
      final pending = Completer<void>();

      unawaited(
        deleteOrderItemMutation((orderId, itemId))
            .run(container, (_) => pending.future),
      );
      await container.pump();

      expect(
        isDeleting(container, orderId),
        isFalse,
        reason: 'deleting an item leaves the order it belongs to',
      );
    });
  });
}
