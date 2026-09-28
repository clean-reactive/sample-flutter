import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/order_entities.dart';
import '../repositories/orders_repository.dart';

class const DeleteOrderUseCase(final Ref _ref) {
  Future<void> call(OrderEntityId orderId) async {
    try {
      await deleteOrderMutation(orderId).run(
        _ref,
        (tsx) =>
            tsx.get(ordersRepositoryProvider.notifier).deleteOrder(orderId),
      );
    } on Object catch (_) {
      // noop
    }
  }
}

final deleteOrderUseCase = Provider<DeleteOrderUseCase>(DeleteOrderUseCase.new);
