import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/order_entities.dart';
import 'order_by_id_selector.dart';

/// Identity of every item in the given order, in the order they were read.
///
/// An order that is not held has no items rather than no answer, which is what
/// lets the unit above render a frame while the read is still in flight.
///
/// An [IList], for the same reason the order ids are: Riverpod compares with
/// `==`, and a plain list is equal only to itself.
final orderItemIdsSelector = Provider.autoDispose
    .family<IList<ItemEntityId>, OrderEntityId>((ref, orderId) {
      final order = ref.watch(orderByIdSelector(orderId));

      return (order?.itemEntities ?? const <ItemEntity>[])
          .map((item) => item.id)
          .toIList();
    });
