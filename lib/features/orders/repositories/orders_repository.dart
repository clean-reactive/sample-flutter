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

/// How many of the repository's writes are in flight.
///
/// Riverpod's mutations are keyed and independent, so each answers only for
/// itself. Nothing can ask them whether *any* write is running, and the unit
/// that renders the feature's status needs exactly that — so the repository
/// counts.
class WritesInFlight extends Notifier<int> {
  @override
  int build() => 0;

  void started() => state = state + 1;

  void finished() => state = state - 1;
}

final writesInFlight = NotifierProvider<WritesInFlight, int>(
  WritesInFlight.new,
);

/// Deletes an order and reads again.
///
/// The operation belongs to the repository because writing to the resource and
/// refreshing what is held are both its business. A use case decides *whether*
/// to call this; it does not decide how a delete reaches the resource.
Future<void> deleteOrder(Ref ref, OrderEntityId orderId) =>
    deleteOrderMutation(orderId).run(
      ref,
      (_) => _write(
        ref,
        () => ref.read(ordersGatewayProvider).deleteOrder(orderId),
      ),
    );

/// Deletes one item of an order and reads again.
Future<void> deleteOrderItem(
  Ref ref,
  OrderEntityId orderId,
  ItemEntityId itemId,
) => deleteOrderItemMutation((orderId: orderId, itemId: itemId)).run(
  ref,
  (_) => _write(
    ref,
    () => ref.read(ordersGatewayProvider).deleteItem(orderId, itemId),
  ),
);

/// Runs a write, counts it while it runs, and reads again when it lands.
///
/// One place says what writing means here, so every operation is counted and
/// every operation refreshes — neither by remembering to.
Future<void> _write(Ref ref, Future<void> Function() operation) async {
  final inFlight = ref.read(writesInFlight.notifier);
  inFlight.started();
  try {
    await operation();
    ref.invalidate(ordersProvider);
  } finally {
    inFlight.finished();
  }
}
