import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/order_entities.dart';
import 'orders_selector.dart';

/// Identity of every order held, in the order they were read.
///
/// The unit that renders orders composes its children by identity rather than
/// by data, so this is what it needs — the ids, not the orders.
///
/// An [IList] rather than a `List`, because Riverpod decides whether to
/// announce a change with `==` and two `List`s are equal only when they are the
/// very same list. A read that returns the same ids would otherwise count as a
/// change every time. An [IList] compares its contents, so this gates itself.
final orderIdsSelector = Provider<IList<OrderEntityId>>(
  (ref) => ref.watch(ordersSelector).map((order) => order.id).toIList(),
);
