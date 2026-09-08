library;

extension type const OrderEntityId(String value) implements String {}

extension type const ItemEntityId(String value) implements String {}

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
