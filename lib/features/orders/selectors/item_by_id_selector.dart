import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/order_entities.dart';
import 'order_by_id_selector.dart';

/// Where an item is: which order holds it, and which item it is.
///
/// A record, so two of these are equal when they name the same item — which is
/// what lets it key a family.
typedef ItemIdentity = ({OrderEntityId orderId, ItemEntityId itemId});

/// The item with the given identity, or none when no such item is held.
///
/// It looks through the order rather than through all orders, because an item's
/// identity is only meaningful within one. It disposes itself, so an item that
/// stops being rendered stops being tracked.
final itemByIdSelector = Provider.autoDispose.family<ItemEntity?, ItemIdentity>(
  (ref, identity) {
    final order = ref.watch(orderByIdSelector(identity.orderId));
    if (order == null) {
      return null;
    }
    for (final item in order.itemEntities) {
      if (item.id == identity.itemId) {
        return item;
      }
    }
    return null;
  },
);
