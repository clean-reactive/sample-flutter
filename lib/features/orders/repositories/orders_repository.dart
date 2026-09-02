/// Repository of the orders read path.
///
/// The composite the architecture calls a repository: a gateway, and the
/// entities it serves. Riverpod supplies both halves — [ordersGatewayProvider]
/// stands where a constructor argument would, and [ordersProvider] holds the
/// entities and notices when they change.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'order_entities.dart';
import 'orders_gateway.dart';
import 'orders_service.dart';

/// External resource the repository reads through.
///
/// Which implementation that is comes from [makeOrdersService]. Overriding this
/// replaces it wholesale, which is how a test supplies its own.
final ordersGatewayProvider = Provider<OrdersGateway>(
  (ref) => makeOrdersService(),
);

/// Orders the repository holds. Absent until a read succeeds.
final ordersProvider = FutureProvider<List<OrderEntity>>(
  (ref) => ref.watch(ordersGatewayProvider).getOrders(),
);
