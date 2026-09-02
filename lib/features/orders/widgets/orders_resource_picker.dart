import 'package:flutter/material.dart';

/// Contracts of the orders resource picker unit.
///
/// Both members are shaped by what the layout binds them to. `SegmentedButton`
/// works in sets of segment values, so the contract speaks in sets too — the
/// unit hands them over untouched instead of converting between a set and a
/// flag on the way past.
abstract interface class OrdersResourcePickerPresenter {
  Set<String> get selectedResources;
}

abstract interface class OrdersResourcePickerController {
  ValueChanged<Set<String>> get resourceSelectionChanged;
}

/// Orders resource picker unit.
///
/// The public entry point of the unit. It takes nothing from its parent — the
/// value it renders and the handler it wires are obtained here.
class OrdersResourcePicker extends StatelessWidget {
  const OrdersResourcePicker({super.key});

  @override
  Widget build(BuildContext context) {
    const selectedResources = {'local'};

    void resourceSelectionChanged(Set<String> selection) {}

    return _UserInterface(
      selectedResources: selectedResources,
      resourceSelectionChanged: resourceSelectionChanged,
    );
  }
}

/// User interface unit of the orders resource picker.
///
/// Primitives in, layout out. It implements both contracts, so its parameters
/// are the contracts rather than merely agreeing with them.
class _UserInterface extends StatelessWidget
    implements OrdersResourcePickerPresenter, OrdersResourcePickerController {
  const _UserInterface({
    required this.selectedResources,
    required this.resourceSelectionChanged,
  });

  @override
  final Set<String> selectedResources;

  @override
  final ValueChanged<Set<String>> resourceSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: 'local', label: Text('Local')),
        ButtonSegment(value: 'remote', label: Text('Remote')),
      ],
      selected: selectedResources,
      onSelectionChanged: resourceSelectionChanged,
    );
  }
}
