import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/orders_repository.dart';
import '../selectors/order_ids_selector.dart';
import 'order.dart';
import 'orders_resource_picker.dart';
import 'orders_statistics.dart';
import 'section_label.dart';

/// Contract of the orders unit.
///
/// The unit renders the feature's frame and composes the child units. It takes
/// no input from the user, so it declares a presenter and no controller.
///
/// [OrdersPresenter.orderIds] composes the child units by identity rather than
/// by data, so each order obtains its own values.
///
/// A record, so it names the values and their types and nothing else. It speaks
/// in plain Dart types, which is what keeps the collection library the selectors
/// use out of the unit that renders them — the values cross this boundary as
/// ordinary data, the way the architecture has data cross a boundary.
typedef OrdersPresenter = ({
  bool isProcessing,
  String statusLabel,
  List<String> orderIds,
});

/// Orders unit.
///
/// The public entry point of the feature. It takes nothing from its parent —
/// the values it renders are obtained here.
class Orders extends ConsumerWidget {
  const Orders({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // presenter
    //
    // The status members come from the read itself rather than from the
    // entities: a first read has nothing to show, a re-read still has the last
    // orders on screen, and the two are worth telling apart.
    final isProcessing = ref.watch(
      ordersProvider.select((orders) => orders.isLoading),
    );
    final statusLabel = ref.watch(
      ordersProvider.select(
        (orders) => switch (orders) {
          _ when !orders.isLoading => 'idle',
          _ when orders.hasValue => 'fetching',
          _ => 'loading',
        },
      ),
    );

    // The selector holds the ids in a list that compares by contents, which is
    // what keeps an unchanged read from rebuilding this unit. The decision is
    // made by `watch` above; converting afterwards costs nothing, and hands the
    // contract an ordinary list.
    final orderIds = ref.watch(orderIdsSelector).toList();

    return _UserInterface(
      presenter: (
        isProcessing: isProcessing,
        statusLabel: statusLabel,
        orderIds: orderIds,
      ),
    );
  }
}

/// User interface unit of the orders feature.
///
/// Primitives in, layout out. Its one parameter is the contract itself, so what
/// it renders cannot drift from what the presenter supplies. It places the
/// child units directly — they carry no data from here, only identity.
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
