import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/order_entities.dart';
import 'orders_selector.dart';

/// The order with the given identity, or none when no such order is held.
///
/// A family, because a unit that renders one order is given identity rather
/// than data and has to find its own. It disposes itself, so an order that
/// stops being rendered stops being tracked.
final orderByIdSelector = Provider.autoDispose
    .family<OrderEntity?, OrderEntityId>((ref, orderId) {
      for (final order in ref.watch(ordersSelector)) {
        if (order.id == orderId) {
          return order;
        }
      }
      return null;
    });
