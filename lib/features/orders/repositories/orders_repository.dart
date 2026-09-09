library;

import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'order_entities.dart';
import 'orders_gateway.dart';
import 'orders_service/orders_service.dart';

class OrdersRepository extends AsyncNotifier<List<OrderEntity>> {
  @override
  Future<List<OrderEntity>> build() =>
      ref.watch(ordersServiceProvider).getOrders();

  void dropOrders() => state = const AsyncData([]);

  Future<void> _write({
    required List<OrderEntity> Function(List<OrderEntity> orders)
    optimistically,
    required Future<void> Function(OrdersGateway gateway) asking,
  }) async {
    final orders = state.requireValue;
    final inFlight = ref.read(ordersRepositoryWritesInFlightProvider.notifier);
    inFlight.started();
    state = AsyncData(optimistically(orders));
    try {
      await asking(ref.read(ordersServiceProvider));
    } on Object {
      state = AsyncData(orders);
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
