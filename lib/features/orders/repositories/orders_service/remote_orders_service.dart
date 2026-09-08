import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../order_entities.dart';
import '../orders_gateway.dart';

/// The remote resource. A real client will live here.
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

final remoteOrdersServiceProvider = Provider<OrdersGateway>(
  (ref) => const RemoteOrdersService(),
);
