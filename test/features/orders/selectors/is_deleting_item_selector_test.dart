import 'dart:async';

import 'package:cleanreactive/features/orders/repositories/order_entities.dart';
import 'package:cleanreactive/features/orders/repositories/orders_repository.dart';
import 'package:cleanreactive/features/orders/selectors/is_deleting_item_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final orderId = OrderEntityId('order-1');
final itemId = ItemEntityId('item-1');
final siblingItemId = ItemEntityId('item-2');

/// Whether the selector reports a delete of [item] in [order] as in flight.
bool isDeleting(
  ProviderContainer container,
  OrderEntityId order,
  ItemEntityId item,
) => container.read(isDeletingItemSelector((order, item)));

void main() {
  group('isDeletingItemSelector', () {
    test('reports nothing in flight when no delete has started', () {
      final container = ProviderContainer.test();

      expect(isDeleting(container, orderId, itemId), isFalse);
    });

    test('reports a delete of the item as in flight', () async {
      final container = ProviderContainer.test();
      final pending = Completer<void>();

      unawaited(
        deleteOrderItemMutation((orderId, itemId))
            .run(container, (_) => pending.future),
      );
      await container.pump();

      expect(isDeleting(container, orderId, itemId), isTrue);
    });

    test('reports nothing in flight once the delete lands', () async {
      final container = ProviderContainer.test();
      final pending = Completer<void>();

      final run = deleteOrderItemMutation((orderId, itemId))
          .run(container, (_) => pending.future);
      await container.pump();
      pending.complete();
      await run;
      await container.pump();

      expect(isDeleting(container, orderId, itemId), isFalse);
    });

    test('reports a delete of the order holding it as in flight', () async {
      final container = ProviderContainer.test();
      final pending = Completer<void>();

      unawaited(
        deleteOrderMutation(orderId).run(container, (_) => pending.future),
      );
      await container.pump();

      expect(
        isDeleting(container, orderId, itemId),
        isTrue,
        reason: 'deleting the order removes the item with it',
      );
    });

    test('reports nothing in flight for an item not being deleted', () async {
      final container = ProviderContainer.test();
      final pending = Completer<void>();

      unawaited(
        deleteOrderItemMutation((orderId, itemId))
            .run(container, (_) => pending.future),
      );
      await container.pump();

      expect(isDeleting(container, orderId, siblingItemId), isFalse);
    });
  });
}
