import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../selectors/item_by_id_selector.dart';
import '../../use_cases/delete_order_item_use_case.dart';
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
    .family<OrderItemPresenter, ItemIdentity>((ref, identity) {
      final productId = ref.watch(
        itemByIdSelector(identity).select((item) => item?.productId ?? ''),
      );
      final quantity = ref.watch(
        itemByIdSelector(identity).select((item) => item?.quantity ?? 0),
      );

      // The item's own delete, and its order's — deleting the last item deletes
      // the order, so this button can be the one that started either.
      final isDeletingItem = ref.watch(
        deleteOrderItemMutation(identity).select(_isPending),
      );
      final isDeletingOrder = ref.watch(
        deleteOrderMutation(identity.orderId).select(_isPending),
      );

      return (
        itemId: identity.itemId,
        productId: productId,
        productQuantity: '$quantity',
        isDeleteItemButtonDisabled: isDeletingItem || isDeletingOrder,
      );
    });

bool _isPending(MutationState<void> state) => state is MutationPending;
