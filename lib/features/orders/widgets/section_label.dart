import 'package:flutter/material.dart';

/// Presentational part shared by the user interface units.
///
/// It declares no presenter or controller of its own — it is a piece of
/// layout, named so the units read declaratively. It is deliberately kept out
/// of the widgets barrel: it carries no contract and is not an architectural
/// unit.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      text,
      style: theme.textTheme.labelSmall?.copyWith(
        letterSpacing: 1.5,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
