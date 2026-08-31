import 'package:flutter/material.dart';

import '../order_item/order_item.dart';

/// Contracts of the order unit.
///
/// [OrderPresenter.itemIds] composes the child units by identity rather than
/// by data, so each order item obtains its own values.
abstract interface class OrderPresenter {
  String get orderId;
  String get userId;
  String get summaryLabel;
  List<String> get itemIds;
}

abstract interface class OrderController {
  /// Null when the action is unavailable. The user interface binds it straight
  /// to the button, which Flutter renders disabled for a null handler, so the
  /// unit carries no logic of its own.
  VoidCallback? get deleteOrderButtonPressed;
}

/// Order unit.
///
/// The public entry point of the unit. Its parameter carries identity, never
/// data: the parent says which order to render, the unit obtains the values
/// itself.
class Order extends StatelessWidget {
  const Order({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    // Stands in for the order's items until the core exists. Both `itemIds`
    // and `summaryLabel` project from it independently — neither contract
    // member is derived from the other.
    const orderItems = ['item-001', 'item-002'];

    final userId = 'user-$orderId';
    final summaryLabel = '${orderItems.length} items';

    void deleteOrderButtonPressed() {}

    return _UserInterface(
      orderId: orderId,
      userId: userId,
      summaryLabel: summaryLabel,
      itemIds: orderItems,
      deleteOrderButtonPressed: deleteOrderButtonPressed,
    );
  }
}

/// User interface unit of the order.
///
/// Primitives in, layout out. It implements both contracts, so its parameters
/// are the contracts rather than merely agreeing with them.
class _UserInterface extends StatelessWidget
    implements OrderPresenter, OrderController {
  const _UserInterface({
    required this.orderId,
    required this.userId,
    required this.summaryLabel,
    required this.itemIds,
    required this.deleteOrderButtonPressed,
  });

  @override
  final String orderId;

  @override
  final String userId;

  @override
  final String summaryLabel;

  @override
  final List<String> itemIds;

  @override
  final VoidCallback? deleteOrderButtonPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      letterSpacing: 1.5,
      color: theme.colorScheme.onSurfaceVariant,
    );

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
                      Text('ORDER', style: labelStyle),
                      const SizedBox(height: 4),
                      Text(orderId, style: theme.textTheme.titleSmall),
                      const SizedBox(height: 4),
                      Text('User $userId', style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: deleteOrderButtonPressed,
                  child: const Text('Delete Order'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Theme(
              data: theme.copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: Text(summaryLabel, style: theme.textTheme.labelMedium),
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
                children: [
                  for (final itemId in itemIds) ...[
                    OrderItem(orderId: orderId, itemId: itemId),
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
