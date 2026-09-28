import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/orders_repository.dart';
import '../stores/toasts_presentation.dart';

/// Announces a read that failed, and renders nothing.
///
/// A read has no use case to catch its error: the failure exists only as state,
/// and reacting to state is a driver's job.
class const OrdersToastDriver({super.key}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final observable = ordersRepositoryProvider.select(
      (orders) => orders.hasError,
    );

    void onChanged(bool? previous, bool next) {
      if (!next || (previous ?? false)) {
        return;
      }
      ref
          .read(toastsPresentationStore.notifier)
          .show('could not read the orders');
    }

    ref.listen(observable, onChanged);

    return const SizedBox.shrink();
  }
}
