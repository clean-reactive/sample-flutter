import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../repositories/order_entities.dart';
import '../../selectors/is_deleting_order_selector.dart';
import '../../selectors/order_by_id_selector.dart';
import '../../selectors/order_item_ids_selector.dart';
import 'order_types.dart';

final orderPresenter = Provider.autoDispose
    .family<OrderPresenter, OrderEntityId>((ref, orderId) {
      final userId = ref.watch(
        orderByIdSelector(orderId).select((order) => order?.userId ?? ''),
      );
      final itemIds = ref.watch(orderItemIdsSelector(orderId));

      return (
        orderId: orderId,
        userId: userId,
        summaryLabel: '${itemIds.length} item${itemIds.length == 1 ? '' : 's'}',
        itemIds: itemIds,
        isDeleteOrderButtonDisabled: ref.watch(
          isDeletingOrderSelector(orderId),
        ),
      );
    });
