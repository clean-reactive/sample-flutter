import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/order_entities.dart';
import '../repositories/orders_repository.dart';

/// Whether a delete of this order is in flight.
final isDeletingOrderSelector = Provider.autoDispose
    .family<bool, OrderEntityId>(
      (ref, orderId) =>
          ref.watch(deleteOrderMutation(orderId).select(_isPending)),
    );

bool _isPending(MutationState<void> state) => state is MutationPending;
