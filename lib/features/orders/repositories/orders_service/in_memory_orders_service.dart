import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../order_entities.dart';
import '../orders_gateway.dart';

/// Local [OrdersGateway], serving orders it holds in memory.
class InMemoryOrdersService implements OrdersGateway {
  /// Holds and mutates the list: it must be growable.
  InMemoryOrdersService(
    this._orders, {
    this.latency = const Duration(seconds: 1),
  });

  final List<OrderEntity> _orders;

  /// Stands in for a real resource's delay, so loading states appear.
  final Duration latency;

  @override
  Future<List<OrderEntity>> getOrders() async {
    await Future<void>.delayed(latency);
    return [..._orders];
  }

  @override
  Future<void> deleteOrder(OrderEntityId orderId) async {
    await Future<void>.delayed(latency);

    final index = _indexOf(orderId);
    _orders.removeAt(index);
  }

  @override
  Future<void> deleteItem(OrderEntityId orderId, ItemEntityId itemId) async {
    await Future<void>.delayed(latency);

    final index = _indexOf(orderId);
    final order = _orders[index];
    _orders[index] = OrderEntity(
      id: order.id,
      userId: order.userId,
      itemEntities: [
        for (final item in order.itemEntities)
          if (item.id != itemId) item,
      ],
    );
  }

  int _indexOf(OrderEntityId orderId) {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index == -1) {
      throw StateError('no order $orderId is held');
    }
    return index;
  }
}

final inMemoryOrdersServiceProvider = Provider<OrdersGateway>(
  (ref) => InMemoryOrdersService(makeOrderEntities()),
);

/// Deterministic seed; users repeat while orders do not.
List<OrderEntity> makeOrderEntities({int orderCount = 3, int itemCount = 2}) =>
    List.generate(
      orderCount,
      (order) => OrderEntity(
        id: OrderEntityId('order-$order'),
        userId: 'user-${order % 2}',
        itemEntities: List.generate(
          itemCount,
          (item) => ItemEntity(
            id: ItemEntityId('item-$order-$item'),
            productId: 'product-$item',
            quantity: item + 1,
          ),
        ),
      ),
    );
