import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/orders_repository.dart';
import '../selectors/orders_selector.dart';
import 'order/order.dart';
import 'orders_resource_picker.dart';
import 'orders_statistics.dart';
import 'section_label.dart';

class const Orders({super.key}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // presenter
    final read = ref.watch(
      ordersRepositoryProvider.select(
        (orders) => (
          isLoading: orders.isLoading,
          hasValue: orders.hasValue,
          hasError: orders.hasError,
        ),
      ),
    );
    final isMutating = ref.watch(
      ordersRepositoryWritesInFlightProvider.select((count) => count > 0),
    );
    final isProcessing = read.isLoading || isMutating;
    final statusLabel = switch ((
      read.isLoading,
      read.hasValue,
      read.hasError,
      isMutating,
    )) {
      (true, false, _, _) => 'loading',
      (true, true, _, _) => 'fetching',
      (false, _, _, true) => 'mutating',
      (false, _, true, _) => 'failed',
      _ => 'idle',
    };

    // An [IList], so an unchanged read compares equal and announces nothing.
    final orderIds = ref.watch(
      ordersSelector.select(
        (orders) => orders.map((order) => order.id).toIList(),
      ),
    );

    // user interface
    final theme = Theme.of(context);

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

          const SectionLabel('RESOURCE'),
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

          const SectionLabel('STATISTICS'),
          const SizedBox(height: 8),
          const OrdersStatistics(),
          const SizedBox(height: 20),

          for (final orderId in orderIds) ...[
            Order(key: ValueKey(orderId), orderId: orderId),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
