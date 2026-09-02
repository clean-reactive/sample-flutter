import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../repositories/order_entities.dart';
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
    final presenter = ref.watch(
      orderItemPresenter((
        orderId: OrderEntityId(orderId),
        itemId: ItemEntityId(itemId),
      )),
    );

    // controller
    //
    // There is no write path yet, so its one member is stood in for.
    void deleteItemButtonPressed() {}

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
