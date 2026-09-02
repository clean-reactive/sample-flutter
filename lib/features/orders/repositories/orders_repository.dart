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

/// External resource the repository reads through.
///
/// It has no default. Which resource is read — local or remote — is chosen at
/// composition, by overriding this, exactly as the contract intends.
final ordersGatewayProvider = Provider<OrdersGateway>(
  (ref) => throw UnimplementedError('no OrdersGateway configured'),
);

/// Orders the repository holds. Absent until a read succeeds.
final ordersProvider = FutureProvider<List<OrderEntity>>(
  (ref) => ref.watch(ordersGatewayProvider).getOrders(),
);
