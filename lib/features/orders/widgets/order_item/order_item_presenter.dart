import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../repositories/order_entities.dart';
import '../../selectors/is_deleting_item_selector.dart';
import '../../selectors/item_by_id_selector.dart';
import 'order_item_types.dart';

/// Presenter of the order item unit.
///
/// A family, because the unit it serves is given identity rather than data, and
/// an item's identity is a pair: which order, and which item within it.
///
/// Each member is read through `select`, so this is rebuilt only when a value
/// it presents has changed — not merely because the orders were read again.
///
/// [OrderItemPresenter.productQuantity] is formatted here. The entity carries a
/// number; the contract asks for text.
final orderItemPresenter = Provider.autoDispose
    .family<OrderItemPresenter, ({OrderEntityId orderId, ItemEntityId itemId})>(
      (ref, identity) {
        final productId = ref.watch(
          itemByIdSelector(identity).select((item) => item?.productId ?? ''),
        );
        final quantity = ref.watch(
          itemByIdSelector(identity).select((item) => item?.quantity ?? 0),
        );

        return (
          itemId: identity.itemId,
          productId: productId,
          productQuantity: '$quantity',
          isDeleteItemButtonDisabled: ref.watch(
            isDeletingItemSelector(identity),
          ),
        );
      },
    );
