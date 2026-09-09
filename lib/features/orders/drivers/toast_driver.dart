import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/orders_repository.dart';

/// renders nothing.
class OrdersToastDriver extends ConsumerWidget {
  const OrdersToastDriver({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final observable = ordersRepositoryProvider.select(
      (orders) => orders.hasError,
    );

    void onChanged(bool? previous, bool next) {
      if (!next || (previous ?? false)) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('could not read the orders')),
      );
    }

    ref.listen(observable, onChanged);

    return const SizedBox.shrink();
  }
}
