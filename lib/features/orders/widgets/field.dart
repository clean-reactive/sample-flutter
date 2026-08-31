import 'package:flutter/material.dart';

/// Presentational part of the order item user interface unit.
///
/// It declares no presenter or controller of its own — it is a piece of the
/// unit's layout, named so the layout reads declaratively. It is deliberately
/// kept out of the widgets barrel: it carries no contract and is not an
/// architectural unit.
class Field extends StatelessWidget {
  const Field({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            letterSpacing: 1.2,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(value, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
