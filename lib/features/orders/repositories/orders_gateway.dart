import 'order_entities.dart';

abstract interface class OrdersGateway {
  Future<List<OrderEntity>> getOrders();

  Future<void> deleteOrder(OrderEntityId orderId);

  Future<void> deleteItem(OrderEntityId orderId, ItemEntityId itemId);
}
