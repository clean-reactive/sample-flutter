import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../selectors/orders_selector.dart';
import '../selectors/total_items_quantity_selector.dart';
import 'pill.dart';

class OrdersStatistics extends ConsumerWidget {
  const OrdersStatistics({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // presenter
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
