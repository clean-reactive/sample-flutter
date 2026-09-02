import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'orders_selector.dart';

/// Total quantity of items across every order held.
///
/// It began inline in the statistics unit, alongside the projections still
/// there, and was given a name once it earned one — it is the one that iterates
/// twice, and the one a second unit is likeliest to want.
///
/// It keeps `select` through that move, so the extraction was a move and
/// nothing else: the same lambda, a new home. It carries the number; turning
/// that into text stays with the unit that renders it.
final totalItemsQuantitySelector = Provider<int>(
  (ref) => ref.watch(
    ordersSelector.select(
      (orders) => orders.fold<int>(
        0,
        (total, order) =>
            total +
            order.itemEntities.fold<int>(
              0,
              (orderTotal, item) => orderTotal + item.quantity,
            ),
      ),
    ),
  ),
);
