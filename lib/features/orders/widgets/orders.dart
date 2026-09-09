import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/orders_repository.dart';
import '../selectors/is_orders_mutating_selector.dart';
import '../selectors/order_ids_selector.dart';
import 'order/order.dart';
import 'orders_resource_picker.dart';
import 'orders_statistics.dart';
import 'section_label.dart';

typedef OrdersPresenter = ({
  bool isProcessing,
  String statusLabel,
  Iterable<String> orderIds,
});

class Orders extends ConsumerWidget {
  const Orders({super.key});

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
    final isMutating = ref.watch(isOrdersMutatingSelector);

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

    final orderIds = ref.watch(orderIdsSelector);

    return _UserInterface(
      presenter: (
        isProcessing: isProcessing,
        statusLabel: statusLabel,
        orderIds: orderIds,
      ),
    );
  }
}

class _UserInterface extends StatelessWidget {
  const _UserInterface({required this.presenter});

  final OrdersPresenter presenter;

  @override
  Widget build(BuildContext context) {
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
                  if (presenter.isProcessing) ...[
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    presenter.statusLabel,
                    style: theme.textTheme.labelMedium,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          const SectionLabel('STATISTICS'),
          const SizedBox(height: 8),
          const OrdersStatistics(),
          const SizedBox(height: 20),

          for (final orderId in presenter.orderIds) ...[
            Order(orderId: orderId),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
