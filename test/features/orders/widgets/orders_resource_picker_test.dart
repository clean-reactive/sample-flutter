import 'package:cleanreactive/features/orders/stores/orders_presentation.dart';
import 'package:cleanreactive/features/orders/widgets/orders_resource_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('picking a resource records the choice', (tester) async {
    final container = ProviderContainer.test();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: OrdersResourcePicker())),
      ),
    );

    expect(
      container.read(ordersPresentationStore).ordersResource,
      OrdersResource.local,
    );

    await tester.tap(find.text('Remote'));
    await tester.pumpAndSettle();

    expect(
      container.read(ordersPresentationStore).ordersResource,
      OrdersResource.remote,
    );

    await tester.tap(find.text('Local'));
    await tester.pumpAndSettle();

    expect(
      container.read(ordersPresentationStore).ordersResource,
      OrdersResource.local,
    );
  });
}
