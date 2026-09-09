import 'package:flutter/widgets.dart';

typedef OrderItemPresenter = ({
  String itemId,
  String productId,
  String productQuantity,
  bool isDeleteItemButtonDisabled,
});

typedef OrderItemController = ({VoidCallback deleteItemButtonPressed});
