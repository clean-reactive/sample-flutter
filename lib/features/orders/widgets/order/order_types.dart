import 'package:flutter/widgets.dart';

typedef OrderPresenter = ({
  String orderId,
  String userId,
  String summaryLabel,
  Iterable<String> itemIds,
  bool isDeleteOrderButtonDisabled,
});

typedef OrderController = ({VoidCallback deleteOrderButtonPressed});
