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
  ) {
    final order = _ref.read(orderByIdSelector(identity.orderId));
    final isLastItem = order?.itemEntities.length == 1;

    if (isLastItem) return _deleteOrder(identity.orderId);

    return _deleteItem(identity);
  }

  /// Each write stops where it is run, for the reason `DeleteOrderUseCase`
  /// stops one: the failure is already the mutation's state and the repository
  /// has already put back what it took, so there is nothing left to decide —
  /// and the controller that started this is not waiting to be told. Caught
  /// here rather than around the choice above, so what this unit exists to
  /// decide reads as the one line it is.
  Future<void> _deleteOrder(OrderEntityId orderId) async {
    try {
      await deleteOrder(_ref, orderId);
    } on Object catch (_) {
      // as above
    }
  }

  /// See [_deleteOrder].
  Future<void> _deleteItem(
    ({OrderEntityId orderId, ItemEntityId itemId}) identity,
  ) async {
    try {
      await deleteOrderItem(_ref, identity.orderId, identity.itemId);
    } on Object catch (_) {
      // as above
    }
  }
}

final deleteOrderItemUseCase = Provider(DeleteOrderItemUseCase.new);
