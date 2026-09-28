import 'package:cleanreactive/features/orders/repositories/orders_repository.dart';
import 'package:cleanreactive/features/orders/repositories/orders_service/orders_service.dart';
import 'package:cleanreactive/features/orders/widgets/order_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' as widgets;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../orders_factory.dart';
import '../repositories/mock_orders_gateway.dart';

/// How many times [OrderItem] is built while [act] runs.
///
/// Counted with Flutter's own rebuild hook, so what is counted is the work the
/// framework does, not what a unit reports about itself.
Future<int> rebuildsOfOrderItem(
  WidgetTester tester,
  Future<void> Function() act,
) async {
  var rebuilds = 0;
  widgets.debugOnRebuildDirtyWidget = (element, _) {
    if (element.widget is OrderItem) {
      rebuilds++;
    }
  };
  addTearDown(() => widgets.debugOnRebuildDirtyWidget = null);
  await act();
  widgets.debugOnRebuildDirtyWidget = null;
  return rebuilds;
}

void main() {
  testWidgets('does not rebuild when a read answers the same item', (
    tester,
  ) async {
    final gateway = MockOrdersGateway();
    // built afresh on every read, the way a real resource answers
    when(gateway.getOrders).thenAnswer(
      (_) async => [
        makeOrder(
          'order-1',
          items: [makeItem('item-1', productId: 'lamp', quantity: 2)],
        ),
      ],
    );
    final container = ProviderContainer.test(
      overrides: [ordersServiceProvider.overrideWithValue(gateway)],
    );
    await container.read(ordersRepositoryProvider.future);

    // placed alone, so nothing above it can rebuild it
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: OrderItem(orderId: 'order-1', itemId: 'item-1'),
          ),
        ),
      ),
    );
    expect(find.text('lamp'), findsOneWidget);

    final rebuilds = await rebuildsOfOrderItem(tester, () async {
      container.invalidate(ordersRepositoryProvider);
      await tester.pumpAndSettle();
    });

    expect(
      rebuilds,
      0,
      reason:
          'the item is a new object, what it shows is not new: the presenter '
          'answers with view values, which compare equal',
    );
  });
}
