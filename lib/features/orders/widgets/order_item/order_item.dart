import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../repositories/order_entities.dart';
import '../../repositories/orders_repository.dart';
import '../../selectors/order_by_id_selector.dart';
import '../field.dart';
import 'order_item_presenter.dart';
import 'order_item_types.dart';

/// Order item unit.
///
/// The public entry point of the unit. Its parameters carry identity, never
/// data: the parent says which item to render, the unit obtains the values
/// itself.
class OrderItem extends ConsumerWidget {
  const OrderItem({super.key, required this.orderId, required this.itemId});

  final String orderId;
  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The parameters arrive as `String`s, because that is what the parent's
    // contract carries. Naming them here is what lets the presenter ask for an
    // item rather than for any pair of strings.
    final identity = (
      orderId: OrderEntityId(orderId),
      itemId: ItemEntityId(itemId),
    );

    final presenter = ref.watch(orderItemPresenter(identity));

    // use case
    //
    // Deletes an item — or the whole order, when the item is its last. That
    // choice is the reason this exists at all. Neither the gateway nor the
    // controller decides it: the gateway offers both operations and chooses
    // neither, and the controller knows only that a button was pressed.
    //
    // Each branch names the mutation its write runs under, keyed by what that
    // write removes: this item, or the order it was the last of. That is what
    // the selectors behind the two buttons read to know one is in flight.
    Future<void> deleteOrderItemUseCase() async {
      final order = ref.read(orderByIdSelector(identity.orderId));
      final isLastItem = order?.itemEntities.length == 1;

      try {
        if (isLastItem) {
          await deleteOrderMutation(identity.orderId).run(
            ref,
            (tsx) => tsx
                .get(ordersRepositoryProvider.notifier)
                .deleteOrder(identity.orderId),
          );
          return;
        }

        await deleteOrderItemMutation(identity).run(
          ref,
          (tsx) => tsx
              .get(ordersRepositoryProvider.notifier)
              .deleteItem(identity.orderId, identity.itemId),
        );
      } on Object catch (_) {
        // recorded by the mutation; the throw stops here
      }
    }

    // controller
    //
    // It converts a press into the use case's terms and nothing else.
    void deleteItemButtonPressed() {
      unawaited(deleteOrderItemUseCase());
    }

    return _UserInterface(
      presenter: presenter,
      controller: (deleteItemButtonPressed: deleteItemButtonPressed),
    );
  }
}

/// User interface unit of the order item.
///
/// Primitives in, layout out. Its parameters are the contracts themselves, so
/// what it renders cannot drift from what supplies it.
class _UserInterface extends StatelessWidget {
  const _UserInterface({required this.presenter, required this.controller});

  final OrderItemPresenter presenter;
  final OrderItemController controller;

  @override
  Widget build(BuildContext context) {
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
                Field(label: 'ID', value: presenter.itemId),
                Field(label: 'PRODUCT ID', value: presenter.productId),
                Field(label: 'QUANTITY', value: presenter.productQuantity),
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: presenter.isDeleteItemButtonDisabled
                ? null
                : controller.deleteItemButtonPressed,
            child: const Text('Delete Item'),
          ),
        ],
      ),
    );
  }
}
