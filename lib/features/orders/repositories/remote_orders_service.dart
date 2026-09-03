import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'order_entities.dart';
import 'orders_gateway.dart';

/// Remote implementation of [OrdersGateway].
///
/// The contract is satisfied in shape but not in substance: there is no
/// external resource behind this yet. It exists so the choice of resource has
/// two sides to it, and so the work of reaching a real service is confined to
/// this file when it arrives.
///
/// [UnimplementedError] rather than [UnsupportedError] on purpose — the
/// operation is coming, it is not being refused.
class RemoteOrdersService implements OrdersGateway {
  const RemoteOrdersService();

  @override
  Future<List<OrderEntity>> getOrders() => throw _unimplemented;

  @override
  Future<void> deleteOrder(OrderEntityId orderId) => throw _unimplemented;

  @override
  Future<void> deleteItem(OrderEntityId orderId, ItemEntityId itemId) =>
      throw _unimplemented;
}

UnimplementedError get _unimplemented =>
    UnimplementedError('no remote resource behind this service yet');

/// The remote resource.
///
/// A provider for the same reason as the local one, though it holds nothing to
/// preserve yet: reaching a real service will mean holding a client, and this
/// is where that will live.
final remoteOrdersServiceProvider = Provider<OrdersGateway>(
  (ref) => const RemoteOrdersService(),
);
