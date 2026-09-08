import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../stores/orders_presentation.dart';
import '../orders_gateway.dart';
import 'in_memory_orders_service.dart';
import 'remote_orders_service.dart';

final ordersServiceProvider = Provider<OrdersGateway>((ref) {
  final resource = ref.watch(
    ordersPresentationStore.select((entity) => entity.ordersResource),
  );

  return switch (resource) {
    OrdersResource.local => ref.watch(inMemoryOrdersServiceProvider),
    OrdersResource.remote => ref.watch(remoteOrdersServiceProvider),
  };
});
