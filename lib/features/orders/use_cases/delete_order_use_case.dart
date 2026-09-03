import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/order_entities.dart';
import '../repositories/orders_repository.dart';

/// Deletes an order.
///
/// It carries no rule of its own — deleting an order means deleting it — so it
/// passes straight to the repository. It exists so the controller has a use
/// case to depend on rather than a repository, which keeps every button in the
/// feature reaching inward the same way.
class DeleteOrderUseCase {
  DeleteOrderUseCase(this._ref);

  final Ref _ref;

  Future<void> execute(OrderEntityId orderId) => deleteOrder(_ref, orderId);
}

final deleteOrderUseCase = Provider(DeleteOrderUseCase.new);
