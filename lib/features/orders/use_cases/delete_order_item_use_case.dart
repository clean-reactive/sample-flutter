import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/order_entities.dart';
import '../repositories/orders_repository.dart';
import '../selectors/order_by_id_selector.dart';

class DeleteOrderItemUseCase {
  const DeleteOrderItemUseCase(this._ref);

  final Ref _ref;

  Future<void> call(
    ({OrderEntityId orderId, ItemEntityId itemId}) identity,
  ) async {
    final order = _ref.read(orderByIdSelector(identity.orderId));
    final isLastItem = order?.itemEntities.length == 1;

    try {
      if (isLastItem) {
        await deleteOrderMutation(identity.orderId).run(
          _ref,
          (tsx) => tsx
              .get(ordersRepositoryProvider.notifier)
              .deleteOrder(identity.orderId),
        );
        return;
      }

      await deleteOrderItemMutation(identity).run(
        _ref,
        (tsx) => tsx
            .get(ordersRepositoryProvider.notifier)
            .deleteItem(identity.orderId, identity.itemId),
      );
    } on Object catch (_) {
      // noop
    }
  }
}

final deleteOrderItemUseCase = Provider<DeleteOrderItemUseCase>(
  DeleteOrderItemUseCase.new,
);
