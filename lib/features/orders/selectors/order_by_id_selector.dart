import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/order_entities.dart';
import 'orders_selector.dart';

final orderByIdSelector = Provider.autoDispose
    .family<OrderEntity?, OrderEntityId>((ref, orderId) {
      for (final order in ref.watch(ordersSelector)) {
        if (order.id == orderId) {
          return order;
        }
      }
      return null;
    });
