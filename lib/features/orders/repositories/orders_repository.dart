/// Repository of the orders read path.
///
/// The composite the architecture calls a repository: a gateway, and the
/// entities it serves. Riverpod supplies both halves — [ordersGatewayProvider]
/// stands where a constructor argument would, and [ordersProvider] holds the
/// entities and notices when they change.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../stores/orders_presentation.dart';
import 'order_entities.dart';
import 'orders_gateway.dart';
import 'orders_service.dart';

/// External resource the repository reads through.
///
/// It watches the resource, so choosing another one rebuilds the gateway, which
/// invalidates [ordersProvider] and reads again. Nothing has to ask for that
/// refresh — it is what depending on the resource means.
///
/// Overriding this replaces the resolution wholesale, which is how a test
/// supplies its own gateway.
final ordersGatewayProvider = Provider<OrdersGateway>(
  (ref) => makeOrdersService(
    ref.watch(
      ordersPresentationStore.select((entity) => entity.ordersResource),
    ),
  ),
);

/// Orders the repository holds. Absent until a read succeeds.
final ordersProvider = FutureProvider<List<OrderEntity>>(
  (ref) => ref.watch(ordersGatewayProvider).getOrders(),
);
