library;

extension type const OrderEntityId(String value) implements String {}

extension type const ItemEntityId(String value) implements String {}

class const ItemEntity({
  required final ItemEntityId id,
  required final String productId,
  required final int quantity,
});

class const OrderEntity({
  required final OrderEntityId id,
  required final String userId,
  required final List<ItemEntity> itemEntities,
});
