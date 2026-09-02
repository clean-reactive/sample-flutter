/// Entities of the orders feature.
///
/// They carry the fields the read path reads and no others — each one traced
/// to the presenter contract that consumes it. Nothing here knows where the
/// values came from or who observes them.
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
