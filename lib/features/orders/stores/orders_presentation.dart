import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Resource the orders are read from.
enum OrdersResource { local, remote }

/// Presentation entity of the orders feature.
///
/// An application business entity: it holds what the application needs in order
/// to present itself, and would not exist if the application did not. Orders
/// exist without this program; the choice of where to read them from does not.
///
/// A record, so two states carrying the same values are equal. That is what
/// keeps the store from announcing a change when nothing has changed.
typedef OrdersPresentationEntity = ({OrdersResource ordersResource});

/// Store of the presentation entity.
///
/// It owns the entity and is the only thing that changes it, which is what
/// makes it a store rather than a variable. Units read the entity from
/// [ordersPresentationStore] and ask this to change it.
class OrdersPresentationStore extends Notifier<OrdersPresentationEntity> {
  @override
  OrdersPresentationEntity build() => (ordersResource: OrdersResource.local);

  void setOrdersResource(OrdersResource resource) =>
      state = (ordersResource: resource);
}

final ordersPresentationStore =
    NotifierProvider<OrdersPresentationStore, OrdersPresentationEntity>(
      OrdersPresentationStore.new,
    );
