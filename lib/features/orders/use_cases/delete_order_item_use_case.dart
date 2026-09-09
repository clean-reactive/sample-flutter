import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/order_entities.dart';
import '../repositories/orders_repository.dart';
import '../selectors/order_by_id_selector.dart';

class DeleteOrderItemUseCase {
  const DeleteOrderItemUseCase(this._ref);

  final Ref _ref;

  Future<void> call(OrderEntityId orderId, ItemEntityId itemId) async {
    final order = _ref.read(orderByIdSelector(orderId));
    final isLastItem = order?.itemEntities.length == 1;

    try {
      if (isLastItem) {
        await deleteOrderMutation(orderId).run(
          _ref,
          (tsx) =>
              tsx.get(ordersRepositoryProvider.notifier).deleteOrder(orderId),
        );
        return;
      }

      await deleteOrderItemMutation((orderId, itemId)).run(
        _ref,
        (tsx) => tsx
            .get(ordersRepositoryProvider.notifier)
            .deleteItem(orderId, itemId),
      );
    } on Object catch (_) {
      // noop
    }
  }
}

final deleteOrderItemUseCase = Provider<DeleteOrderItemUseCase>(
  DeleteOrderItemUseCase.new,
);
