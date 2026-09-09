import 'package:flutter_riverpod/flutter_riverpod.dart';

enum OrdersResource { local, remote }

typedef OrdersPresentationEntity = ({OrdersResource ordersResource});

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
