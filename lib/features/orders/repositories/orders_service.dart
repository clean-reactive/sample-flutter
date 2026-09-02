import 'in_memory_orders_service.dart';
import 'orders_gateway.dart';

/// Resolves which implementation sits behind [OrdersGateway].
///
/// One resource exists, so it resolves to one thing. It is here as a seam
/// rather than as a choice: when a second implementation appears, this is where
/// the resource is picked, and nothing that reads orders has to learn about it.
///
/// It is a function rather than a class of static methods, which is how Dart
/// spells this — a class would be a namespace and nothing else.
OrdersGateway makeOrdersService() => InMemoryOrdersService();
