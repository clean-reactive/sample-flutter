import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/order_entities.dart';
import '../repositories/orders_repository.dart';
import '../stores/toasts_presentation.dart';

class const DeleteOrderUseCase(final Ref _ref) {
  Future<void> call(OrderEntityId orderId) async {
    try {
      await deleteOrderMutation(orderId).run(
        _ref,
        (tsx) =>
            tsx.get(ordersRepositoryProvider.notifier).deleteOrder(orderId),
      );
    } on Object catch (_) {
      _ref
          .read(toastsPresentationStore.notifier)
          .show('could not delete the order');
    }
  }
}

final deleteOrderUseCase = Provider<DeleteOrderUseCase>(DeleteOrderUseCase.new);
