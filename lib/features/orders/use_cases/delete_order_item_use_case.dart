import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/order_entities.dart';
import '../repositories/orders_repository.dart';
import '../selectors/order_by_id_selector.dart';

/// Deletes an item — or the whole order, when the item is its last.
///
/// That choice is the reason this unit exists. Neither the gateway nor the
/// widget decides it: the gateway offers both operations and chooses neither,
/// and the widget knows only that a button was pressed.
class DeleteOrderItemUseCase {
  DeleteOrderItemUseCase(this._ref);

  final Ref _ref;

  Future<void> execute(
    ({OrderEntityId orderId, ItemEntityId itemId}) identity,
  ) async {
    final order = _ref.read(orderByIdSelector(identity.orderId));
    final isLastItem = order?.itemEntities.length == 1;

    try {
      await (isLastItem
          ? _deleteOrder(identity.orderId)
          : _deleteItem(identity));
    } on Object catch (_) {
      // Both writes stop here, for the reason `DeleteOrderUseCase` stops one:
      // the failure is already the mutation's state, and the controller that
      // started this is not waiting to be told.
    }
  }

  Future<void> _deleteOrder(OrderEntityId orderId) =>
      deleteOrder(_ref, orderId);

  Future<void> _deleteItem(
    ({OrderEntityId orderId, ItemEntityId itemId}) identity,
  ) => deleteOrderItem(_ref, identity.orderId, identity.itemId);
}

final deleteOrderItemUseCase = Provider(DeleteOrderItemUseCase.new);
