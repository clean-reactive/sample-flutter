import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/orders_repository.dart';
import '../stores/orders_presentation.dart';

/// Orders resource picker unit.
///
/// The public entry point of the unit. It takes nothing from its parent — the
/// value it renders and the handler it wires are obtained here.
///
/// Laid out the way the statistics unit is: the units are inlined in `build`
/// and marked by comment. This one has a controller where that one has none,
/// because it takes input from the user.
class OrdersResourcePicker extends ConsumerWidget {
  const OrdersResourcePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // presenter
    //
    // `SegmentedButton` works in sets of segment values, so this hands one over
    // untouched rather than converting between a set and a flag on the way
    // past.
    final selectedResources = {
      ref.watch(
        ordersPresentationStore.select((entity) => entity.ordersResource),
      ),
    };

    // controller
    //
    // The button allows neither an empty selection nor several, so what it
    // reports always holds exactly one.
    //
    // The orders held were read from the resource being left, so they go with
    // it. They are dropped before the choice is recorded: the read that
    // follows keeps whatever is held when it starts.
    void resourceSelectionChanged(Set<OrdersResource> selection) {
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
