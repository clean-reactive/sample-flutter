import 'package:cleanreactive/features/orders/selectors/total_items_quantity_selector.dart';
import 'package:flutter_test/flutter_test.dart';

import '../orders_factory.dart';

void main() {
  group('selectTotalItemsQuantity', () {
    test('is nothing when there are no orders', () {
      expect(selectTotalItemsQuantity([]), 0);
    });

    test('is nothing when the orders hold no items', () {
      expect(selectTotalItemsQuantity([makeOrder('order-1')]), 0);
    });

    test('adds up the quantities of every item of every order', () {
      final total = selectTotalItemsQuantity([
        makeOrder(
          'order-1',
          items: [
            makeItem('item-1', quantity: 2),
            makeItem('item-2', quantity: 5),
          ],
        ),
        makeOrder('order-2', items: [makeItem('item-3', quantity: 3)]),
      ]);

      // 2 + 5 from the first order, 3 from the second. Distinct from the number
      // of items (3) and from either order's own total (7 and 3).
      expect(total, 10);
    });
  });
}
