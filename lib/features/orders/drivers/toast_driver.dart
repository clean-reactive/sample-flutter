import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/orders_repository.dart';
import '../stores/toasts_presentation.dart';

/// Announces a read or a write that failed, and renders nothing.
///
/// Neither failure has anything left alive to catch it: a read is started by
/// the repository itself, and a write outlives the widget that asked for it.
/// Both exist only as the repository's state, and reacting to state is a
/// driver's job.
class const OrdersToastDriver({super.key}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toasts = ref.read(toastsPresentationStore.notifier);

    ref.listen(ordersRepositoryProvider.select((orders) => orders.hasError), (
      bool? previous,
      bool next,
    ) {
      if (!next || (previous ?? false)) {
        return;
      }
      toasts.show('could not read the orders');
    });

    ref.listen(ordersRepositoryFailedWriteProvider, (_, failed) {
      if (failed == null) {
        return;
      }
      toasts.show(switch (failed.write) {
        OrdersWrite.deleteOrder => 'could not delete the order',
        OrdersWrite.deleteItem => 'could not delete the item',
      });
    });

    return const SizedBox.shrink();
  }
}
