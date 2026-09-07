/// A gateway a test drives.
///
/// The gateway is where the feature ends and something else begins, so it is
/// the one place a double belongs. Everything on this side of it — repository,
/// selectors, use cases, presenters — is ours, and a test that replaced any of
/// it would be checking that we wrote what we wrote.
///
/// A full fake rather than `extends Fake`: the repository calls all three
/// methods, so nothing is left for `noSuchMethod` to refuse. Reach for
/// `extends Fake implements OrdersGateway` where a test genuinely supports only
/// part of the interface, and calls to the rest should throw.
library;

import 'package:cleanreactive/features/orders/repositories/order_entities.dart';
import 'package:cleanreactive/features/orders/repositories/orders_gateway.dart';

class FakeOrdersGateway implements OrdersGateway {
  /// What each call answers.
  ///
  /// One field per method, each replaceable on its own, so a test scripts the
  /// operation its case is about and leaves the others alone. Holding the
  /// behaviour in a field rather than branching on state inside the fake keeps
  /// what the double will do readable at the point the test says it:
  ///
  /// ```dart
  /// gateway.onGetOrders = () async => [makeOrder('order-1')];
  /// gateway.onDeleteOrder = (_) => Completer<void>().future;  // never lands
  /// gateway.onGetOrders = () async => throw Exception('unreachable');
  /// ```
  ///
  /// The defaults answer rather than refuse — an empty read, a write that
  /// succeeds — because most tests care about one operation and would
  /// otherwise have to script the ones they are indifferent to.
  Future<List<OrderEntity>> Function() onGetOrders = () async => const [];
  Future<void> Function(OrderEntityId orderId) onDeleteOrder = (_) async {};
  Future<void> Function(OrderEntityId orderId, ItemEntityId itemId)
  onDeleteItem = (_, _) async {};

  @override
  Future<List<OrderEntity>> getOrders() => onGetOrders();

  @override
  Future<void> deleteOrder(OrderEntityId orderId) => onDeleteOrder(orderId);

  @override
  Future<void> deleteItem(OrderEntityId orderId, ItemEntityId itemId) =>
      onDeleteItem(orderId, itemId);
}
