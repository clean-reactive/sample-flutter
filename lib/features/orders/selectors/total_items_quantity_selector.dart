import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/order_entities.dart';
import 'orders_selector.dart';

int selectTotalItemsQuantity(List<OrderEntity> orders) => orders.fold<int>(
  0,
  (total, order) =>
      total +
      order.itemEntities.fold<int>(
        0,
        (orderTotal, item) => orderTotal + item.quantity,
      ),
);

final totalItemsQuantitySelector = Provider<int>(
  (ref) => ref.watch(ordersSelector.select(selectTotalItemsQuantity)),
);
