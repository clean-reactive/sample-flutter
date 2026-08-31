import 'package:flutter/material.dart';

import 'order.dart';
import 'orders_resource_picker.dart';
import 'orders_statistics.dart';

/// Contract of the orders unit.
///
/// The unit renders the feature's frame and composes the child units. It takes
/// no input from the user, so it declares a presenter and no controller.
///
/// [OrdersPresenter.orderIds] composes the child units by identity rather than
/// by data, so each order obtains its own values.
abstract interface class OrdersPresenter {
  bool get isProcessing;
  String get statusLabel;
  List<String> get orderIds;
}

/// Orders unit.
///
/// The public entry point of the feature. It takes nothing from its parent —
/// the values it renders are obtained here.
class Orders extends StatelessWidget {
  const Orders({super.key});

  @override
  Widget build(BuildContext context) {
    const isProcessing = true;
    const statusLabel = 'Processing';
    const orderIds = ['order-a1b2c3', 'order-d4e5f6'];

    return const _UserInterface(
      isProcessing: isProcessing,
      statusLabel: statusLabel,
      orderIds: orderIds,
    );
  }
}

/// User interface unit of the orders feature.
///
/// Primitives in, layout out. It implements `OrdersPresenter`, so its
/// parameters are the contract rather than merely agreeing with it. It places
/// the child units directly — they carry no data from here, only identity.
class _UserInterface extends StatelessWidget implements OrdersPresenter {
  const _UserInterface({
    required this.isProcessing,
    required this.statusLabel,
    required this.orderIds,
  });

  @override
  final bool isProcessing;

  @override
  final String statusLabel;

  @override
  final List<String> orderIds;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      letterSpacing: 1.5,
      color: theme.colorScheme.onSurfaceVariant,
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'ORDERS',
            style: theme.textTheme.titleMedium?.copyWith(letterSpacing: 2),
          ),
          const SizedBox(height: 20),

          Text('RESOURCE', style: labelStyle),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const OrdersResourcePicker(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isProcessing) ...[
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(statusLabel, style: theme.textTheme.labelMedium),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          Text('STATISTICS', style: labelStyle),
          const SizedBox(height: 8),
          const OrdersStatistics(),
          const SizedBox(height: 20),

          for (final orderId in orderIds) ...[
            Order(orderId: orderId),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
