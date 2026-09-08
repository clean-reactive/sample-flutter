import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/order_entities.dart';
import '../repositories/orders_repository.dart';

/// Deletes an order.
///
/// It carries no rule of its own about *what* to delete — deleting an order
/// means deleting it — so it passes straight to the repository. It exists so
/// the controller has a use case to depend on rather than a repository, which
/// keeps every button in the feature reaching inward the same way, and so that
/// a delete that fails has a unit whose business that is.
class DeleteOrderUseCase {
  DeleteOrderUseCase(this._ref);

  final Ref _ref;

  Future<void> execute(OrderEntityId orderId) async {
    try {
      await deleteOrder(_ref, orderId);
    } on Object catch (_) {
      // A refused delete is not exceptional to the caller. The repository has
      // already put the order back, and the mutation the write ran under holds
      // the failure for whatever renders it — so the application has nothing
      // left to decide, and the error has somewhere to stop. The controller
      // starts this and does not wait for it; anything let past here would
      // surface as an unhandled error instead of as state.
    }
  }
}

final deleteOrderUseCase = Provider(DeleteOrderUseCase.new);
