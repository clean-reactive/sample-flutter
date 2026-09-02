import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/order_entities.dart';
import '../repositories/orders_repository.dart';

/// Orders held, or none while the first read is in flight.
///
/// It answers the absent case once so no projection has to repeat it, which is
/// what earned it a name: every unit that reads orders was carrying the same
/// `?? const []` of its own.
///
/// It is the entities as the read path sees them. Units project from here
/// rather than from the repository, so what a read is doing stays the
/// repository's business and not theirs.
final ordersSelector = Provider<List<OrderEntity>>(
  (ref) =>
      ref.watch(ordersProvider.select((orders) => orders.value ?? const [])),
);
