import 'package:flutter/widgets.dart';

/// Contracts of the order item unit.
///
/// Records, so each names the values and their types and nothing else.
///
/// They have a file of their own so the unit's parts can each depend on them
/// without depending on one another: the presenter supplies these values, the
/// widget renders them, and neither imports the other's file.
typedef OrderItemPresenter = ({
  String itemId,
  String productId,
  String productQuantity,
  bool isDeleteItemButtonDisabled,
});

typedef OrderItemController = ({VoidCallback deleteItemButtonPressed});
