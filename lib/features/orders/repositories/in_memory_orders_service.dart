import 'order_entities.dart';
import 'orders_gateway.dart';

/// Local implementation of [OrdersGateway].
///
/// It serves orders it holds in memory, which is what makes the feature
/// runnable with no service behind it.
class InMemoryOrdersService implements OrdersGateway {
  const InMemoryOrdersService({
    this.orders = localOrders,
    this.latency = const Duration(seconds: 1),
  });

  /// Orders this instance serves.
  final List<OrderEntity> orders;

  /// Stands in for the time a real resource would take.
  ///
  /// Without it the read resolves in the same frame it starts, and the states
  /// the read path exists to express — loading, then loaded — never appear.
  final Duration latency;

  @override
  Future<List<OrderEntity>> getOrders() async {
    await Future<void>.delayed(latency);
    return orders;
  }
}

/// Orders the local resource serves unless it is given others.
const localOrders = [
  OrderEntity(
    id: OrderEntityId('order-8c41'),
    userId: 'user-204',
    itemEntities: [
      ItemEntity(
        id: ItemEntityId('item-1f0a'),
        productId: 'product-77',
        quantity: 3,
      ),
      ItemEntity(
        id: ItemEntityId('item-2b93'),
        productId: 'product-12',
        quantity: 1,
      ),
    ],
  ),
  OrderEntity(
    id: OrderEntityId('order-d5e7'),
    userId: 'user-511',
    itemEntities: [
      ItemEntity(
        id: ItemEntityId('item-3c48'),
        productId: 'product-05',
        quantity: 4,
      ),
    ],
  ),
  OrderEntity(
    id: OrderEntityId('order-a962'),
    userId: 'user-204',
    itemEntities: [
      ItemEntity(
        id: ItemEntityId('item-4d1b'),
        productId: 'product-77',
        quantity: 2,
      ),
      ItemEntity(
        id: ItemEntityId('item-5e60'),
        productId: 'product-33',
        quantity: 6,
      ),
    ],
  ),
];
