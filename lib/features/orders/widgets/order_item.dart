import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/order_entities.dart';
import '../repositories/orders_repository.dart';
import '../selectors/is_deleting_order_selector.dart';
import '../selectors/order_by_id_selector.dart';
import 'field.dart';

/// Presenter, controller with an inline use case, and user interface inlined in
/// one component.
///
/// Extraction follows need: the `Order` branch shows these units extracted,
/// and nothing here has needed it yet.
class const OrderItem({
  super.key,
  required final String orderId,
  required final String itemId,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderEntityId = OrderEntityId(orderId);
    final itemEntityId = ItemEntityId(itemId);

    // presenter; answers with view values rather than the entity, so a read
    // that brings the same item as a new object compares equal
    final item = ref.watch(
      orderByIdSelector(orderEntityId).select((order) {
        // selector
        final item = order?.itemEntities
            .where((item) => item.id == itemEntityId)
            .firstOrNull;
        if (item == null) {
          return null;
        }
        return (productId: item.productId, quantity: '${item.quantity}');
      }),
    );
    final isDeletingItem = ref.watch(
      deleteOrderItemMutation((orderEntityId, itemEntityId))
          .select((state) => state is MutationPending),
    );
    final isDeletingOrder = ref.watch(isDeletingOrderSelector(orderEntityId));
    final isDeleteItemButtonDisabled = isDeletingItem || isDeletingOrder;

    // controller with an inline use case; decisions read entities, not display
    // values. It starts the write and waits for nothing: the optimistic delete
    // takes this widget off the screen, and a failure is the repository's state
    // for a driver to announce.
    void deleteItemButtonPressed() {
      final order = ref.read(orderByIdSelector(orderEntityId));
      final isLastItem = order?.itemEntities.length == 1;

      if (isLastItem) {
        deleteOrderMutation(orderEntityId)
            .run(
              ref,
              (tsx) => tsx
                  .get(ordersRepositoryProvider.notifier)
                  .deleteOrder(orderEntityId),
            )
            .ignore();
        return;
      }

      deleteOrderItemMutation((orderEntityId, itemEntityId))
          .run(
            ref,
            (tsx) => tsx
                .get(ordersRepositoryProvider.notifier)
                .deleteItem(orderEntityId, itemEntityId),
          )
          .ignore();
    }

    // user interface
    if (item == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 24,
              runSpacing: 8,
              children: [
                Field(label: 'ID', value: itemId),
                Field(label: 'PRODUCT ID', value: item.productId),
                Field(label: 'QUANTITY', value: item.quantity),
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: isDeleteItemButtonDisabled
                ? null
                : deleteItemButtonPressed,
            child: const Text('Delete Item'),
          ),
        ],
      ),
    );
  }
}
