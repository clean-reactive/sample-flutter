import 'package:flutter/material.dart';

import 'field.dart';

/// Contracts of the order item unit.
abstract interface class OrderItemPresenter {
  String get itemId;
  String get productId;
  String get productQuantity;
  bool get isDeleteItemButtonDisabled;
}

abstract interface class OrderItemController {
  VoidCallback get deleteItemButtonPressed;
}

/// Order item unit.
///
/// The public entry point of the unit. Its parameters carry identity, never
/// data: the parent says which item to render, the unit obtains the values
/// itself.
class OrderItem extends StatelessWidget {
  const OrderItem({super.key, required this.orderId, required this.itemId});

  final String orderId;
  final String itemId;

  @override
  Widget build(BuildContext context) {
    final itemId = '$orderId-${this.itemId}';
    final productId = 'product-$orderId-${this.itemId}';
    const productQuantity = '3';
    const isDeleteItemButtonDisabled = false;

    void deleteItemButtonPressed() {}

    return _UserInterface(
      itemId: itemId,
      productId: productId,
      productQuantity: productQuantity,
      isDeleteItemButtonDisabled: isDeleteItemButtonDisabled,
      deleteItemButtonPressed: deleteItemButtonPressed,
    );
  }
}

/// User interface unit of the order item.
///
/// Primitives in, layout out. It implements both contracts, so its parameters
/// are the contracts rather than merely agreeing with them.
class _UserInterface extends StatelessWidget
    implements OrderItemPresenter, OrderItemController {
  const _UserInterface({
    required this.itemId,
    required this.productId,
    required this.productQuantity,
    required this.isDeleteItemButtonDisabled,
    required this.deleteItemButtonPressed,
  });

  @override
  final String itemId;

  @override
  final String productId;

  @override
  final String productQuantity;

  @override
  final bool isDeleteItemButtonDisabled;

  @override
  final VoidCallback deleteItemButtonPressed;

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
                Field(label: 'ID', value: itemId),
                Field(label: 'PRODUCT ID', value: productId),
                Field(label: 'QUANTITY', value: productQuantity),
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
