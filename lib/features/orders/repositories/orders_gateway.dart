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
/// The signature takes no parameters and describes no status. Which resource
/// is read — local or remote — selects the implementation placed behind this
/// interface; it is not an argument. Whether a read is in flight is the
/// repository's concern, not this one's. A future that completes or throws is
/// the whole contract.
abstract interface class OrdersGateway {
  Future<List<OrderEntity>> getOrders();
}
