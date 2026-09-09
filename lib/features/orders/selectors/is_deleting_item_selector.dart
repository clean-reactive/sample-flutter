import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/order_entities.dart';
import '../repositories/orders_repository.dart';
import 'is_deleting_order_selector.dart';

final isDeletingItemSelector = Provider.autoDispose
    .family<bool, (OrderEntityId, ItemEntityId)>((ref, identity) {
      final (orderId, _) = identity;

      final isDeletingItem = ref.watch(
        deleteOrderItemMutation(identity).select(_isPending),
      );
      final isDeletingOrder = ref.watch(isDeletingOrderSelector(orderId));

      return isDeletingItem || isDeletingOrder;
    });

bool _isPending(MutationState<void> state) => state is MutationPending;
