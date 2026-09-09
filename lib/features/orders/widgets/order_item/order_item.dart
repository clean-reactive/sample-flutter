import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../repositories/order_entities.dart';
import '../field.dart';
import 'order_item_controller.dart';
import 'order_item_presenter.dart';
import 'order_item_types.dart';

/// Presenter, controller and user interface each extracted into their own unit.
///
/// The presenter is watched and the controller is read: renders follow the read
/// path, and a controller nothing subscribes to cannot cause one.
class OrderItem extends ConsumerWidget {
  const OrderItem({super.key, required this.orderId, required this.itemId});

  final String orderId;
  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final identity = (OrderEntityId(orderId), ItemEntityId(itemId));

    return _UserInterface(
      presenter: ref.watch(orderItemPresenter(identity)),
      controller: ref.read(orderItemController(identity)),
    );
  }
}

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
