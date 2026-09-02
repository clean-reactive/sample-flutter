/// Core of the orders feature: the entities the read path serves, and the
/// gateway contract that supplies them.
///
/// The units start inlined in one file and are split out as continuous
/// refactoring earns it. What is here now is what the read path has reached —
/// the entities and `Gateway<I>`. The repository that composes them follows.
library;

/// Identity of an order.
///
/// A distinct type over `String`, so an arbitrary string cannot stand in for
/// an order's identity. It implements `String`, which keeps the relation
/// one-way: an [OrderEntityId] is accepted wherever a `String` is expected —
/// `OrdersPresenter.orderIds` and `OrderPresenter.orderId` are declared in
/// primitives and stay that way — while a bare `String` is not accepted here.
extension type const OrderEntityId(String value) implements String {}

/// Identity of an item within an order.
extension type const ItemEntityId(String value) implements String {}

/// Item of an order.
///
/// It carries the fields the read path reads and no others.
/// `OrderPresenter.itemIds` reads [id], `OrderItemPresenter.productId` reads
/// [productId], and [quantity] is read twice — by
/// `OrderItemPresenter.productQuantity` for a single item, and by
/// `OrdersStatisticsPresenter.totalItemsQuantity` summed across all of them.
///
/// [quantity] is an `int` even though both contract members that render it
/// declare `String`. The entity holds the fact, the presenter formats it.
class ItemEntity {
  const ItemEntity({
    required this.id,
    required this.productId,
    required this.quantity,
  });

  final ItemEntityId id;
  final String productId;
  final int quantity;
}

/// Order.
///
/// [userId] is read by `OrderPresenter.userId` for one order, and counted
/// distinctly by `OrdersStatisticsPresenter.usersCount` across all of them.
///
/// [itemEntities] nests rather than being fetched on its own: the item values
/// are needed at the same moment the order list is, so the read path never has
/// a reason to ask for them separately.
class OrderEntity {
  const OrderEntity({
    required this.id,
    required this.userId,
    required this.itemEntities,
  });

  final OrderEntityId id;
  final String userId;
  final List<ItemEntity> itemEntities;
}

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
