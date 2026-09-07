/// A gateway a test drives.
///
/// The gateway is where the feature ends and something else begins, so it is
/// the one place a double belongs. Everything on this side of it — repository,
/// selectors, use cases, presenters — is ours, and a test that replaced any of
/// it would be checking that we wrote what we wrote.
library;

import 'package:cleanreactive/features/orders/repositories/orders_gateway.dart';
import 'package:mocktail/mocktail.dart';

class MockOrdersGateway extends Mock implements OrdersGateway {
  /// Comes answering: an empty read, and writes that succeed.
  ///
  /// A test then scripts the operation its case is about and stays silent
  /// about the ones it is indifferent to. Stubbed here rather than by a
  /// separate factory, so there is one name for a gateway a test can use, and
  /// no way to end up with one that refuses every call.
  MockOrdersGateway() {
    when(getOrders).thenAnswer((_) async => const []);
    when(() => deleteOrder(any())).thenAnswer((_) async {});
    when(() => deleteItem(any(), any())).thenAnswer((_) async {});
  }
}
