import 'package:cleanreactive/features/orders/repositories/orders_repository.dart';
import 'package:cleanreactive/features/orders/repositories/orders_service.dart';
import 'package:cleanreactive/features/orders/selectors/order_ids_selector.dart';
import 'package:cleanreactive/features/orders/stores/orders_presentation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('the resolved orders service', () {
    test('keeps what was written when the resource is chosen again', () async {
      final container = ProviderContainer.test();
      await container.read(ordersProvider.future);
      final before = container.read(orderIdsSelector);

      // written through the gateway, because what is under test is which
      // service answers — not what any caller of it decides to do
      await container.read(ordersGatewayProvider).deleteOrder(before.first);
      container.invalidate(ordersProvider);
      await container.read(ordersProvider.future);

      final afterDelete = container.read(orderIdsSelector);
      expect(afterDelete.length, before.length - 1);

      // away to the other resource and back
      final store = container.read(ordersPresentationStore.notifier);
      store.setOrdersResource(OrdersResource.remote);
      await expectLater(
        container.read(ordersProvider.future),
        throwsUnimplementedError,
      );
      store.setOrdersResource(OrdersResource.local);
      await container.read(ordersProvider.future);

      expect(
        container.read(orderIdsSelector),
        afterDelete,
        reason: 'a second local service would start from the seed again',
      );
    });
  });
}
