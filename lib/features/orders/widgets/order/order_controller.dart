import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../repositories/order_entities.dart';
import '../../use_cases/delete_order_use_case.dart';
import 'order_types.dart';

final orderController = Provider.autoDispose
    .family<OrderController, OrderEntityId>((ref, orderId) {
      final executeDeleteOrder = ref.read(deleteOrderUseCase);

      return (
        deleteOrderButtonPressed: () => unawaited(executeDeleteOrder(orderId)),
      );
    });
