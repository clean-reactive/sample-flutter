import 'order_entities.dart';

/// Contract of the external resource the orders core reads from.
///
/// It is extracted from the read path's consumers rather than designed
/// upfront, which is why it carries a single operation. Every consumer
/// projects from one collection: `OrdersStatisticsPresenter` needs all of it,
/// and `OrderPresenter` and `OrderItemPresenter` take identity rather than
/// data, so they select from what is already loaded. Nothing asks for one
/// order, so nothing offers one.
///
/// The signatures take no resource and describe no status. Which resource is
/// read — local or remote — selects the implementation placed behind this
/// interface; it is not an argument. Whether an operation is in flight is the
/// caller's concern, not this one's. A future that completes or throws is the
/// whole contract.
///
/// [deleteOrder] sits beside [deleteItem] because deleting an item can mean
/// deleting its order, and deciding which is the use case's business. This
/// interface offers both and chooses neither.
abstract interface class OrdersGateway {
  Future<List<OrderEntity>> getOrders();

  Future<void> deleteOrder(OrderEntityId orderId);

  Future<void> deleteItem(OrderEntityId orderId, ItemEntityId itemId);
}
