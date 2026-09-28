import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/order_entities.dart';
import '../repositories/orders_repository.dart';

/// Starts the delete and waits for nothing.
///
/// The optimistic delete takes the order that asked for it off the screen, and
/// this use case goes with it. What happens after — the order put back, the
/// failure recorded — belongs to the repository, and a driver announces it.
class const DeleteOrderUseCase(final Ref _ref) {
  void call(OrderEntityId orderId) => deleteOrderMutation(orderId)
      .run(
        _ref,
        (tsx) =>
            tsx.get(ordersRepositoryProvider.notifier).deleteOrder(orderId),
      )
      .ignore();
}

final deleteOrderUseCase = Provider.autoDispose<DeleteOrderUseCase>(
  DeleteOrderUseCase.new,
);
