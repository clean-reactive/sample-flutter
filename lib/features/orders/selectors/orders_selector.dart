import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/order_entities.dart';
import '../repositories/orders_repository.dart';

final ordersSelector = Provider<List<OrderEntity>>(
  (ref) => ref.watch(
    ordersRepositoryProvider.select((orders) => orders.value ?? const []),
  ),
);
