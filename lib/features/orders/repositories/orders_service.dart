import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../stores/orders_presentation.dart';
import 'in_memory_orders_service.dart';
import 'orders_gateway.dart';
import 'remote_orders_service.dart';

/// The service standing behind [OrdersGateway].
///
/// It picks between services rather than building them. Each is a unit with a
/// lifetime of its own — the local one holds the orders, so building a second
/// would lose everything written to the first — so this reads them from where
/// they live and chooses.
///
/// It watches the resource, so choosing another one rebuilds this, which
/// invalidates what depends on it and reads again. Nothing has to ask for that
/// refresh; it is what depending on the resource means.
///
/// Overriding this replaces the resolution wholesale, which is how a test
/// supplies its own gateway.
final ordersGatewayProvider = Provider<OrdersGateway>((ref) {
  final resource = ref.watch(
    ordersPresentationStore.select((entity) => entity.ordersResource),
  );

  return switch (resource) {
    OrdersResource.local => ref.watch(inMemoryOrdersServiceProvider),
    OrdersResource.remote => ref.watch(remoteOrdersServiceProvider),
  };
});
