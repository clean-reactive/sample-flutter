import 'package:flutter/material.dart';

class const SectionLabel(final String text, {super.key})
    extends StatelessWidget {
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
