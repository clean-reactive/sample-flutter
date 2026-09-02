import 'order_entities.dart';
import 'orders_gateway.dart';

/// Local implementation of [OrdersGateway].
///
/// It serves orders it holds in memory, which is what makes the feature
/// runnable with no service behind it.
class InMemoryOrdersService implements OrdersGateway {
  InMemoryOrdersService({
    List<OrderEntity>? orders,
    this.latency = const Duration(seconds: 1),
  }) : orders = orders ?? localOrders;

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
final localOrders = makeOrderEntities();

/// Builds [orderCount] orders holding [itemCount] items each.
///
/// Deterministic on purpose. A local resource that served different numbers on
/// every run would make the values the feature renders unrepeatable, and those
/// values are the thing worth looking at.
///
/// The users repeat while the orders do not, so the statistics unit has a user
/// count that differs from its order count — two projections that would
/// otherwise be impossible to tell apart.
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
