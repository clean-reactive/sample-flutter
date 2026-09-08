/// Repository of the orders read path.
///
/// The composite the architecture calls a repository: a gateway, and the
/// entities it serves. [ordersProvider] holds the entities and notices when
/// they change; which gateway serves them is resolved next door, in
/// `orders_service.dart`.
library;

import 'dart:math';

import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'order_entities.dart';
import 'orders_service.dart';

/// An order taken out of what is held, and the place it was taken from.
///
/// Position is part of what was removed. An order put back at the end would be
/// a different screen from the one the user was looking at.
typedef RemovedOrder = ({int index, OrderEntity order});

/// An item taken out of the order that held it, and the place it was taken
/// from.
///
/// It names the order rather than where the order sat, because the order may
/// have moved by the time the item goes back — and may be gone, which is an
/// answer too.
typedef RemovedItem = ({OrderEntityId orderId, int index, ItemEntity item});

/// Orders the repository holds. Absent until a read succeeds.
///
/// A notifier rather than a bare read, because the repository writes to what it
/// holds as well as reading it. A delete takes the order out at once and asks
/// the resource afterwards, so the screen answers the press rather than the
/// round trip — which means there has to be something to take it out of, and
/// something to put it back into when the resource refuses.
class HeldOrders extends AsyncNotifier<List<OrderEntity>> {
  @override
  Future<List<OrderEntity>> build() =>
      ref.watch(ordersGatewayProvider).getOrders();

  /// Takes [orderId] out of what is held, and answers with what was taken.
  ///
  /// Answers with nothing when no such order is held — there is then nothing to
  /// undo either, which is the same answer [restoreOrder] is given.
  RemovedOrder? removeOrder(OrderEntityId orderId) {
    final held = state.value ?? const <OrderEntity>[];
    final index = held.indexWhere((order) => order.id == orderId);
    if (index < 0) return null;

    state = AsyncData([...held]..removeAt(index));
    return (index: index, order: held[index]);
  }

  /// Puts [removed] back where it was, and does nothing when nothing was taken.
  ///
  /// It inserts into whatever is held at the moment it is called rather than
  /// restoring the list it replaced: another delete may have landed in between,
  /// and undoing this one must not bring that one back. Its place is clamped
  /// for the same reason — the list it is returning to may be shorter than the
  /// one it left.
  void restoreOrder(RemovedOrder? removed) {
    if (removed == null) return;

    final held = state.value ?? const <OrderEntity>[];
    state = AsyncData(
      [...held]..insert(min(removed.index, held.length), removed.order),
    );
  }

  /// Takes [identity] out of the order that holds it, and answers with what was
  /// taken.
  ///
  /// Answers with nothing when no such order or no such item is held.
  RemovedItem? removeItem(
    ({OrderEntityId orderId, ItemEntityId itemId}) identity,
  ) {
    final held = state.value ?? const <OrderEntity>[];
    final orderIndex = held.indexWhere((order) => order.id == identity.orderId);
    if (orderIndex < 0) return null;

    final order = held[orderIndex];
    final index = order.itemEntities.indexWhere(
      (item) => item.id == identity.itemId,
    );
    if (index < 0) return null;

    state = AsyncData(
      [...held]
        ..[orderIndex] = _withItems(
          order,
          [...order.itemEntities]..removeAt(index),
        ),
    );
    return (
      orderId: identity.orderId,
      index: index,
      item: order.itemEntities[index],
    );
  }

  /// Puts [removed] back where it was, and does nothing when nothing was taken.
  ///
  /// Nothing to do either when the order it belonged to is no longer held: its
  /// own delete landed while this one was in flight, and an order that is gone
  /// takes its items with it.
  void restoreItem(RemovedItem? removed) {
    if (removed == null) return;

    final held = state.value ?? const <OrderEntity>[];
    final orderIndex = held.indexWhere((order) => order.id == removed.orderId);
    if (orderIndex < 0) return;

    final order = held[orderIndex];
    state = AsyncData(
      [...held]
        ..[orderIndex] = _withItems(
          order,
          [...order.itemEntities]..insert(
            min(removed.index, order.itemEntities.length),
            removed.item,
          ),
        ),
    );
  }

  /// [order] with [items] in place of the ones it holds.
  ///
  /// An entity is not changed but replaced: what is held is a new list of new
  /// orders, so a selector comparing what it was given can tell that it has.
  OrderEntity _withItems(OrderEntity order, List<ItemEntity> items) =>
      OrderEntity(id: order.id, userId: order.userId, itemEntities: items);
}

final ordersProvider = AsyncNotifierProvider<HeldOrders, List<OrderEntity>>(
  HeldOrders.new,
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

/// Deletes an order, optimistically, and reads again.
///
/// The order leaves the repository before the gateway is called, so every unit
/// that projects from the entities answers the press in the same frame it
/// happened. What the resource says afterwards either agrees — and the read
/// changes nothing — or refuses, and the order goes back where it was.
///
/// The operation belongs to the repository because writing to the resource and
/// changing what is held are both its business. A use case decides *whether* to
/// call this; it does not decide how a delete reaches the resource, nor what
/// being optimistic about one means.
Future<void> deleteOrder(Ref ref, OrderEntityId orderId) =>
    deleteOrderMutation(orderId).run(ref, (tsx) {
      // Read through the transaction, which holds the notifier open for as long
      // as the mutation runs: the last unit rendering this order has just been
      // told the order is gone, and without this the notifier it was keeping
      // alive could be disposed while the write is still in flight.
      final removed = tsx.get(ordersProvider.notifier).removeOrder(orderId);

      return _write(
        ref,
        () => ref.read(ordersGatewayProvider).deleteOrder(orderId),
        // Read again rather than closed over: a delete that lands in the
        // meantime rebuilds the notifier, and what is held then is what this
        // has to put the order back into.
        undo: () => ref.read(ordersProvider.notifier).restoreOrder(removed),
      );
    });

/// Deletes one item of an order, optimistically, and reads again.
///
/// The order stays; the item leaves it before the gateway is called, so the
/// card the user is looking at answers the press rather than the round trip.
/// What the resource says afterwards either agrees, or refuses and the item
/// goes back into the order it came from.
Future<void> deleteOrderItem(
  Ref ref,
  OrderEntityId orderId,
  ItemEntityId itemId,
) {
  final identity = (orderId: orderId, itemId: itemId);

  return deleteOrderItemMutation(identity).run(ref, (tsx) {
    final removed = tsx.get(ordersProvider.notifier).removeItem(identity);

    return _write(
      ref,
      () => ref.read(ordersGatewayProvider).deleteItem(orderId, itemId),
      undo: () => ref.read(ordersProvider.notifier).restoreItem(removed),
    );
  });
}

/// Runs a write, counts it while it runs, and reads again when it lands.
///
/// One place says what writing means here, so every operation is counted and
/// every operation refreshes — neither by remembering to.
///
/// [undo] takes back what the write assumed before it ran. It is called when
/// the operation fails and never otherwise. Every write here assumes something,
/// so every write says how to take it back.
Future<void> _write(
  Ref ref,
  Future<void> Function() operation, {
  required void Function() undo,
}) async {
  final inFlight = ref.read(writesInFlight.notifier);
  inFlight.started();
  try {
    await operation();
    ref.invalidate(ordersProvider);
  } catch (_) {
    undo();
    rethrow;
  } finally {
    inFlight.finished();
  }
}
