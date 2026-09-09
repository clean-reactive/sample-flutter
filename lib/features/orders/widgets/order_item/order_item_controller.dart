import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../repositories/order_entities.dart';
import '../../use_cases/delete_order_item_use_case.dart';
import 'order_item_types.dart';

final orderItemController = Provider.autoDispose
    .family<OrderItemController, (OrderEntityId, ItemEntityId)>((
      ref,
      identity,
    ) {
      final (orderId, itemId) = identity;
      final executeDeleteOrderItem = ref.read(deleteOrderItemUseCase);

      return (
        deleteItemButtonPressed: () =>
            unawaited(executeDeleteOrderItem(orderId, itemId)),
      );
    });
