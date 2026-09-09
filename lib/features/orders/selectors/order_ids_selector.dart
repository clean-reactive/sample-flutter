import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/order_entities.dart';
import 'orders_selector.dart';

/// An [IList], so an unchanged read compares equal and announces nothing.
final orderIdsSelector = Provider<IList<OrderEntityId>>(
  (ref) => ref.watch(ordersSelector).map((order) => order.id).toIList(),
);
