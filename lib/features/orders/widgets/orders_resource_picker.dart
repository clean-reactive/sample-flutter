import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/orders_repository.dart';
import '../stores/orders_presentation.dart';

/// Presenter, controller and user interface inlined in one component.
///
/// All three units are here and marked, none is extracted: one reading of the
/// resource in use, one handler that changes it, and the buttons that show it.
/// Extraction follows need, and nothing here has needed it yet.
class OrdersResourcePicker extends ConsumerWidget {
  const OrdersResourcePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // presenter
    final selectedResources = {
      ref.watch(
        ordersPresentationStore.select((entity) => entity.ordersResource),
      ),
    };

    // controller
    void resourceSelectionChanged(Set<OrdersResource> selection) {
      // The orders belong to the resource being left, so they are dropped
      // before the choice is recorded.
      ref.read(ordersRepositoryProvider.notifier).dropOrders();
      ref
          .read(ordersPresentationStore.notifier)
          .setOrdersResource(selection.first);
    }

    // user interface
    return SegmentedButton<OrdersResource>(
      segments: const [
        ButtonSegment(value: OrdersResource.local, label: Text('Local')),
        ButtonSegment(value: OrdersResource.remote, label: Text('Remote')),
      ],
      selected: selectedResources,
      onSelectionChanged: resourceSelectionChanged,
    );
  }
}
