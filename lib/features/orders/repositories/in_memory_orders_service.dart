import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'order_entities.dart';
import 'orders_gateway.dart';

/// Local implementation of [OrdersGateway].
///
/// It serves orders it holds in memory, which is what makes the feature
/// runnable with no service behind it.
class InMemoryOrdersService implements OrdersGateway {
  /// Takes the orders it is to hold and does nothing else with them. Deciding
  /// what a local resource starts with is [make]'s business, not a
  /// constructor's.
  ///
  /// The list is held, not copied, and is written to — so it must be one the
  /// caller is willing to give up, and a growable one. A `const` list will
  /// serve reads and throw on the first delete.
  InMemoryOrdersService(
    this._orders, {
    this.latency = const Duration(seconds: 1),
  });

  /// Orders this instance holds.
  ///
  /// Mutable, because it stands in for a resource that is written to as well as
  /// read.
  final List<OrderEntity> _orders;

  /// Stands in for the time a real resource would take.
  ///
  /// Without it the read resolves in the same frame it starts, and the states
  /// the read path exists to express — loading, then loaded — never appear.
  final Duration latency;

  @override
  Future<List<OrderEntity>> getOrders() async {
    await Future<void>.delayed(latency);
    return [..._orders];
  }

  @override
  Future<void> deleteOrder(OrderEntityId orderId) async {
    await Future<void>.delayed(latency);

    final index = _indexOf(orderId);
    _orders.removeAt(index);
  }

  @override
  Future<void> deleteItem(OrderEntityId orderId, ItemEntityId itemId) async {
    await Future<void>.delayed(latency);

    final index = _indexOf(orderId);
    final order = _orders[index];
    _orders[index] = OrderEntity(
      id: order.id,
      userId: order.userId,
      itemEntities: [
        for (final item in order.itemEntities)
          if (item.id != itemId) item,
      ],
    );
  }

  int _indexOf(OrderEntityId orderId) {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index == -1) {
      throw StateError('no order $orderId is held');
    }
    return index;
  }
}

/// The local resource.
///
/// This is where a local resource is built, and so the one place that says what
/// it starts with.
///
/// One instance for as long as the container lives, because it holds the orders
/// rather than fetching them: a second would start from the seed again and
/// every delete made against the first would come back. Choosing another
/// resource and returning must not undo what was written.
///
/// The instance belongs to the container rather than to the class. A `static`
/// one would outlive any single run — which reads the same in an application,
/// and leaks one test's writes into the next.
final inMemoryOrdersServiceProvider = Provider<OrdersGateway>(
  (ref) => InMemoryOrdersService(makeOrderEntities()),
);

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
