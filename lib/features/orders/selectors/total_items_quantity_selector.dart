import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/order_entities.dart';
import 'orders_selector.dart';

/// Total quantity of items across [orders].
///
/// A function, because that is all it is: entities in, a number out, no
/// container and no notion of when it runs. Naming it puts the arithmetic
/// somewhere a test can reach it directly, and leaves the provider below with
/// only the one thing a provider decides — what it watches.
int selectTotalItemsQuantity(List<OrderEntity> orders) => orders.fold<int>(
  0,
  (total, order) =>
      total +
      order.itemEntities.fold<int>(
        0,
        (orderTotal, item) => orderTotal + item.quantity,
      ),
);

/// Total quantity of items across every order held.
///
/// It began inline in the statistics unit, alongside the projections still
/// there, and was given a name once it earned one — it is the one that iterates
/// twice, and the one a second unit is likeliest to want.
///
/// It carries the number; turning that into text stays with the unit that
/// renders it.
final totalItemsQuantitySelector = Provider<int>(
  (ref) => ref.watch(ordersSelector.select(selectTotalItemsQuantity)),
);
