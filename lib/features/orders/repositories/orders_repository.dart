/// Repository of the orders read path.
///
/// The composite the architecture calls a repository: a gateway, and the
/// entities it serves. [ordersProvider] holds the entities and notices when
/// they change; which gateway serves them is resolved next door, in
/// `orders_service.dart`.
library;

import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'order_entities.dart';
import 'orders_service.dart';

/// Orders the repository holds. Absent until a read succeeds.
final ordersProvider = FutureProvider<List<OrderEntity>>(
  (ref) => ref.watch(ordersGatewayProvider).getOrders(),
);

/// State of the repository's delete operations, one per order and one per item.
///
/// Keyed, so each operation is told apart from every other. Riverpod compares
/// keys with `==`, which is why a record works: two identities naming the same
/// item are the same key.
///
/// They are declared here rather than where they are run, because what is in
/// flight is the repository's state. A use case starts one; a selector reads
/// one; neither has to know about the other.
final deleteOrderMutation = Mutation<void>();
final deleteOrderItemMutation = Mutation<void>();

/// Deletes an order and reads again.
///
/// The operation belongs to the repository because writing to the resource and
/// refreshing what is held are both its business. A use case decides *whether*
/// to call this; it does not decide how a delete reaches the resource.
Future<void> deleteOrder(Ref ref, OrderEntityId orderId) =>
    deleteOrderMutation(orderId).run(ref, (_) async {
      await ref.read(ordersGatewayProvider).deleteOrder(orderId);
      ref.invalidate(ordersProvider);
    });

/// Deletes one item of an order and reads again.
Future<void> deleteOrderItem(
  Ref ref,
  OrderEntityId orderId,
  ItemEntityId itemId,
) => deleteOrderItemMutation((orderId: orderId, itemId: itemId))
    .run(ref, (_) async {
      await ref.read(ordersGatewayProvider).deleteItem(orderId, itemId);
      ref.invalidate(ordersProvider);
    });
