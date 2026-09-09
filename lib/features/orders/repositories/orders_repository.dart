library;

import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'order_entities.dart';
import 'orders_gateway.dart';
import 'orders_service/orders_service.dart';

typedef _OrdersChange = List<OrderEntity> Function(List<OrderEntity> orders);

class OrdersRepository extends AsyncNotifier<List<OrderEntity>> {
  /// The orders the changes are held on top of.
  List<OrderEntity> _base = const [];

  /// The orders this repository put there itself, last time it did.
  List<OrderEntity> _held = const [];

  /// The changes held on top of [_base], in the order they were asked for. A
  /// write that fails drops its own and the rest are held again: putting back
  /// a snapshot would take back the changes of the writes still in flight.
  final _changes = <Object, _OrdersChange>{};

  @override
  Future<List<OrderEntity>> build() =>
      ref.watch(ordersServiceProvider).getOrders();

  void dropOrders() => state = const AsyncData([]);

  void _hold(List<OrderEntity> orders) {
    _held = orders;
    state = AsyncData(orders);
  }

  List<OrderEntity> _changed() =>
      _changes.values.fold(_base, (orders, change) => change(orders));

  Future<void> _write({
    required _OrdersChange optimistically,
    required Future<void> Function(OrdersGateway gateway) asking,
  }) async {
    final orders = state.requireValue;
    if (!identical(orders, _held)) {
      // Orders something other than a write put there — a read that landed, or
      // a drop. They are what the changes from here are held on top of.
      _changes.clear();
      _base = orders;
    }

    final write = Object();
    final inFlight = ref.read(ordersRepositoryWritesInFlightProvider.notifier);
    inFlight.started();
    _changes[write] = optimistically;
    _hold(_changed());
    try {
      await asking(ref.read(ordersServiceProvider));
    } on Object {
      _changes.remove(write);
      _hold(_changed());
      rethrow;
    } finally {
      inFlight.finished();
    }
    // A read started while other writes are in flight answers without what
    // they have not landed yet, standing deleted orders back up. Only the
    // write that finishes last reads.
    if (ref.read(ordersRepositoryWritesInFlightProvider) == 0) {
      ref.invalidateSelf();
    }
  }

  Future<void> deleteOrder(OrderEntityId orderId) => _write(
    optimistically: (orders) => [
      for (final order in orders)
        if (order.id != orderId) order,
    ],
    asking: (gateway) => gateway.deleteOrder(orderId),
  );

  Future<void> deleteItem(OrderEntityId orderId, ItemEntityId itemId) => _write(
    optimistically: (orders) => [
      for (final order in orders)
        if (order.id == orderId)
          OrderEntity(
            id: order.id,
            userId: order.userId,
            itemEntities: [
              for (final item in order.itemEntities)
                if (item.id != itemId) item,
            ],
          )
        else
          order,
    ],
    asking: (gateway) => gateway.deleteItem(orderId, itemId),
  );
}

final deleteOrderMutation = Mutation<void>();
final deleteOrderItemMutation = Mutation<void>();

final ordersRepositoryProvider =
    AsyncNotifierProvider<OrdersRepository, List<OrderEntity>>(
      OrdersRepository.new,
    );

class OrdersRepositoryWritesInFlight extends Notifier<int> {
  @override
  int build() => 0;

  void started() => state = state + 1;

  void finished() => state = state - 1;
}

final ordersRepositoryWritesInFlightProvider =
    NotifierProvider<OrdersRepositoryWritesInFlight, int>(
      OrdersRepositoryWritesInFlight.new,
    );
