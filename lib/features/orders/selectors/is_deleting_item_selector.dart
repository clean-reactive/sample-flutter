import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/order_entities.dart';
import '../repositories/orders_repository.dart';
import 'is_deleting_order_selector.dart';

/// Whether a delete that would remove this item is in flight.
///
/// Its own delete, or its order's — deleting an order's last item deletes the
/// order, so the operation that removes an item can be either.
///
/// It exists so the read path can answer this without reaching for the unit
/// that starts a delete. The repository holds what is in flight; this reads it,
/// and a presenter reads this.
final isDeletingItemSelector = Provider.autoDispose
    .family<bool, ({OrderEntityId orderId, ItemEntityId itemId})>((
      ref,
      identity,
    ) {
      final isDeletingItem = ref.watch(
        deleteOrderItemMutation(identity).select(_isPending),
      );
      final isDeletingOrder = ref.watch(
        isDeletingOrderSelector(identity.orderId),
      );

      return isDeletingItem || isDeletingOrder;
    });

bool _isPending(MutationState<void> state) => state is MutationPending;
