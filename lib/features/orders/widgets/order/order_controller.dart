import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../repositories/order_entities.dart';
import '../../use_cases/delete_order_use_case.dart';
import 'order_types.dart';

/// Never watches state: a controller sits on the write path, and state it
/// watched would rebuild the widget that holds it. It watches the use case, a
/// unit that never changes, so the use case lives as long as it does.
final orderController = Provider.autoDispose
    .family<OrderController, OrderEntityId>((ref, orderId) {
      final executeDeleteOrder = ref.watch(deleteOrderUseCase);

      return (deleteOrderButtonPressed: () => executeDeleteOrder(orderId));
    });
