import 'package:flutter/widgets.dart';

/// Contracts of the order unit.
///
/// [OrderPresenter.itemIds] composes the child units by identity rather than by
/// data, so each order item obtains its own values.
///
/// Records, so each names the values and their types and nothing else. They
/// speak in plain Dart types, which keeps the collection library the selectors
/// use out of the unit that renders them.
///
/// They have a file of their own so the unit's parts can each depend on them
/// without depending on one another: the presenter supplies these values, the
/// widget renders them, and neither imports the other's file.
typedef OrderPresenter = ({
  String orderId,
  String userId,
  String summaryLabel,
  List<String> itemIds,
  bool isDeleteOrderButtonDisabled,
});

typedef OrderController = ({VoidCallback deleteOrderButtonPressed});
