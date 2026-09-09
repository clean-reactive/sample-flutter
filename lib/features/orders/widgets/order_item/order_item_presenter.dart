import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../repositories/order_entities.dart';
import '../../selectors/is_deleting_item_selector.dart';
import '../../selectors/item_by_id_selector.dart';
import 'order_item_types.dart';

final orderItemPresenter = Provider.autoDispose
    .family<OrderItemPresenter, (OrderEntityId, ItemEntityId)>((ref, identity) {
      final (_, itemId) = identity;

      final productId = ref.watch(
        itemByIdSelector(identity).select((item) => item?.productId ?? ''),
      );
      final quantity = ref.watch(
        itemByIdSelector(identity).select((item) => item?.quantity ?? 0),
      );

      return (
        itemId: itemId,
        productId: productId,
        productQuantity: '$quantity',
        isDeleteItemButtonDisabled: ref.watch(isDeletingItemSelector(identity)),
      );
    });
