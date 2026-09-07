/// Builders for the entities and the local resource the orders tests run on.
///
/// The application seeds itself with `makeOrderEntities`, which answers one
/// question — what a local resource starts with. A test asks the opposite: it
/// wants exactly the orders its case is about and nothing more. These builders
/// name every value a test cares about and default the rest, so a fixture reads
/// as the case it stands for.
///
/// Identities stay positional and required. They are what tests assert on, and
/// a generated one would let an expectation be derived from the same rule that
/// produced it — the test would then agree with itself rather than with the
/// code.
library;

import 'package:cleanreactive/features/orders/repositories/order_entities.dart';

/// An item of an order.
///
/// [quantity] defaults to 1 rather than 0, so summing across items cannot pass
/// by adding nothing.
ItemEntity makeItem(
  String id, {
  String productId = 'product',
  int quantity = 1,
}) =>
    ItemEntity(id: ItemEntityId(id), productId: productId, quantity: quantity);

/// An order, holding [items].
///
/// Defaults to no items: most cases are about which orders exist, not what is
/// inside them, and an empty order says so.
OrderEntity makeOrder(
  String id, {
  String userId = 'user-a',
  List<ItemEntity> items = const [],
}) => OrderEntity(id: OrderEntityId(id), userId: userId, itemEntities: items);
