import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/order_entities.dart';
import 'order_by_id_selector.dart';

/// An [IList], so an unchanged read compares equal and announces nothing.
final orderItemIdsSelector = Provider.autoDispose
    .family<IList<ItemEntityId>, OrderEntityId>((ref, orderId) {
      final order = ref.watch(orderByIdSelector(orderId));

      return (order?.itemEntities ?? const <ItemEntity>[])
          .map((item) => item.id)
          .toIList();
    });
