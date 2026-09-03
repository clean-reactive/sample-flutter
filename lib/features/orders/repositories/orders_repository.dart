/// Repository of the orders read path.
///
/// The composite the architecture calls a repository: a gateway, and the
/// entities it serves. [ordersProvider] holds the entities and notices when
/// they change; which gateway serves them is resolved next door, in
/// `orders_service.dart`.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'order_entities.dart';
import 'orders_service.dart';

/// Orders the repository holds. Absent until a read succeeds.
final ordersProvider = FutureProvider<List<OrderEntity>>(
  (ref) => ref.watch(ordersGatewayProvider).getOrders(),
);
