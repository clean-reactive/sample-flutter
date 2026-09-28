import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../repositories/order_entities.dart';
import '../order_item.dart';
import '../section_label.dart';
import 'order_controller.dart';
import 'order_presenter.dart';
import 'order_types.dart';

/// Presenter, controller and user interface each extracted into their own unit.
///
/// Both are watched, so each lives exactly as long as this widget. Renders
/// still follow the read path only: the controller watches nothing, so it never
/// announces a new value and never causes one.
class const Order({super.key, required final String orderId})
    extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = OrderEntityId(orderId);

    return _UserInterface(
      presenter: ref.watch(orderPresenter(id)),
      controller: ref.watch(orderController(id)),
    );
  }
}

class const _UserInterface({
  required final OrderPresenter presenter,
  required final OrderController controller,
}) extends StatelessWidget {
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
                    OrderItem(
                      key: ValueKey(itemId),
                      orderId: presenter.orderId,
                      itemId: itemId,
                    ),
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
