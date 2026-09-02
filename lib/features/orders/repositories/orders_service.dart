import '../stores/orders_presentation.dart';
import 'in_memory_orders_service.dart';
import 'orders_gateway.dart';
import 'remote_orders_service.dart';

/// Resolves which implementation sits behind [OrdersGateway].
///
/// It takes the resource rather than reaching for it. A function given a `Ref`
/// could reach anything; this one can only answer the question it was asked,
/// and answering it needs no container — `makeOrdersService(OrdersResource.remote)`
/// is a complete call.
///
/// Where the resource comes from is the repository's business, which is the
/// only place that has to know the store exists.
OrdersGateway makeOrdersService(OrdersResource resource) => switch (resource) {
  OrdersResource.local => InMemoryOrdersService(),
  OrdersResource.remote => const RemoteOrdersService(),
};
