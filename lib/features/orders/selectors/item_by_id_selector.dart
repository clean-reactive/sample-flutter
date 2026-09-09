import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/order_entities.dart';
import 'order_by_id_selector.dart';

/// The item with the given identity, or none when no such item is held.
///
/// An item is identified by a pair — which order holds it, and which item it is
/// — passed as a record, because a family compares its keys with `==` and two
/// records naming the same item are equal. The two are branded, so neither can
/// be passed for the other and the pair needs no field names.
///
/// It looks through the order rather than through all orders, because an item's
/// identity is only meaningful within one. It disposes itself, so an item that
/// stops being rendered stops being tracked.
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
