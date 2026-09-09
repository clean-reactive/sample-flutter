import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../repositories/order_entities.dart';
import '../../use_cases/delete_order_item_use_case.dart';
import '../field.dart';
import 'order_item_presenter.dart';
import 'order_item_types.dart';

class OrderItem extends ConsumerWidget {
  const OrderItem({super.key, required this.orderId, required this.itemId});

  final String orderId;
  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderEntityId = OrderEntityId(orderId);
    final itemEntityId = ItemEntityId(itemId);

    final executeDeleteOrderItem = ref.read(deleteOrderItemUseCase);

    // presenter
    final presenter = ref.watch(
      orderItemPresenter((orderEntityId, itemEntityId)),
    );

    // controller
    void deleteItemButtonPressed() {
      unawaited(executeDeleteOrderItem(orderEntityId, itemEntityId));
    }

    return _UserInterface(
      presenter: presenter,
      controller: (deleteItemButtonPressed: deleteItemButtonPressed),
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
