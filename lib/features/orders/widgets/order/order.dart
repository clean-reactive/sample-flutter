import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:async';

import '../../repositories/order_entities.dart';
import '../../use_cases/delete_order_use_case.dart';
import '../order_item/order_item.dart';
import '../section_label.dart';
import 'order_presenter.dart';
import 'order_types.dart';

/// Order unit.
///
/// The public entry point of the unit. Its parameter carries identity, never
/// data: the parent says which order to render, the unit obtains the values
/// itself.
class Order extends ConsumerWidget {
  const Order({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The parameter arrives as a `String`, because that is what the parent's
    // contract carries. Naming it here is what lets the presenter ask for an
    // order rather than for any string that happens to look like one.
    final id = OrderEntityId(orderId);

    final presenter = ref.watch(orderPresenter(id));

    // controller
    //
    // It turns a press into the use case's terms and nothing else.
    void deleteOrderButtonPressed() {
      unawaited(ref.read(deleteOrderUseCase).execute(id));
    }

    return _UserInterface(
      presenter: presenter,
      controller: (deleteOrderButtonPressed: deleteOrderButtonPressed),
    );
  }
}

/// User interface unit of the order.
///
/// Primitives in, layout out. Its parameters are the contracts themselves, so
/// what it renders cannot drift from what supplies it.
class _UserInterface extends StatelessWidget {
  const _UserInterface({required this.presenter, required this.controller});

  final OrderPresenter presenter;
  final OrderController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SectionLabel('ORDER'),
                      const SizedBox(height: 4),
                      Text(
                        presenter.orderId,
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'User ${presenter.userId}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: presenter.isDeleteOrderButtonDisabled
                      ? null
                      : controller.deleteOrderButtonPressed,
                  child: const Text('Delete Order'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Theme(
              data: theme.copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: Text(
                  presenter.summaryLabel,
                  style: theme.textTheme.labelMedium,
                ),
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
                children: [
                  for (final itemId in presenter.itemIds) ...[
                    OrderItem(orderId: presenter.orderId, itemId: itemId),
                    const SizedBox(height: 4),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
