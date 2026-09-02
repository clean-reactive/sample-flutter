import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../repositories/order_entities.dart';
import '../../selectors/order_by_id_selector.dart';
import '../../selectors/order_item_ids_selector.dart';
import 'order_types.dart';

/// Presenter of the order unit.
///
/// A family, because the unit it serves is given identity rather than data.
/// Each order asks for its own, and the presenter finds it.
///
/// It reads through `select` and through selectors that compare by contents, so
/// it is rebuilt only when a value it presents has changed — not merely because
/// the orders were read again.
///
/// [OrderPresenter.itemIds] and [OrderPresenter.summaryLabel] project from the
/// same ids independently. Neither is derived from the other's rendering.
final orderPresenter = Provider.autoDispose
    .family<OrderPresenter, OrderEntityId>((ref, orderId) {
      final userId = ref.watch(
        orderByIdSelector(orderId).select((order) => order?.userId ?? ''),
      );
      final itemIds = ref.watch(orderItemIdsSelector(orderId)).toList();

      return (
        orderId: orderId,
        userId: userId,
        summaryLabel: '${itemIds.length} item${itemIds.length == 1 ? '' : 's'}',
        itemIds: itemIds,
        // True while a delete for this order is in flight. Nothing can be in
        // flight until there is a write path, so this is the value rather than
        // a stand-in for one.
        isDeleteOrderButtonDisabled: false,
      );
    });
