import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/order_entities.dart';
import 'order_by_id_selector.dart';

final itemByIdSelector = Provider.autoDispose
    .family<ItemEntity?, (OrderEntityId, ItemEntityId)>((ref, identity) {
      final (orderId, itemId) = identity;

      final order = ref.watch(orderByIdSelector(orderId));
      if (order == null) {
        return null;
      }
      for (final item in order.itemEntities) {
        if (item.id == itemId) {
          return item;
        }
      }
      return null;
    });
