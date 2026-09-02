import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../selectors/orders_selector.dart';
import '../selectors/total_items_quantity_selector.dart';
import 'pill.dart';

/// Orders statistics unit.
///
/// The public entry point of the unit. It takes nothing from its parent — the
/// values it renders are obtained here, so a caller only places the widget.
///
/// Every unit of the read path the feature owns is inlined in `build` and
/// marked by comment: the entities arrive through the repository, the presenter
/// projects and formats them, and the user interface lays them out. That is the
/// shape a feature starts in. Each earns a file of its own when something asks
/// for it — a contract worth holding both ends to, a layout worth rendering
/// without a container, a projection a second unit wants — and not before.
///
/// The repository stays outside because it is shared and owns the read.
class OrdersStatistics extends ConsumerWidget {
  const OrdersStatistics({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // presenter
    //
    // The entities arrive through `ordersSelector`, which is where the absent
    // case is answered.
    //
    // Each projection is watched through `select`, so this unit rebuilds only
    // when a value it renders has changed — not merely because the orders did.
    // It is also the form a selector starts in: `totalItemsQuantitySelector`
    // left this list that way, moving its lambda without rewriting it.
    final usersCount = ref.watch(
      ordersSelector.select(
        (orders) => '${orders.map((order) => order.userId).toSet().length}',
      ),
    );
    final ordersCount = ref.watch(
      ordersSelector.select((orders) => '${orders.length}'),
    );
    final itemsCount = ref.watch(
      ordersSelector.select(
        (orders) =>
            '${orders.fold<int>(0, (count, order) => count + order.itemEntities.length)}',
      ),
    );
    final totalItemsQuantity = '${ref.watch(totalItemsQuantitySelector)}';

    // user interface
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        Pill(value: usersCount, label: 'users'),
        Pill(value: ordersCount, label: 'orders'),
        Pill(value: itemsCount, label: 'items'),
        Pill(value: totalItemsQuantity, label: 'qty'),
      ],
    );
  }
}
