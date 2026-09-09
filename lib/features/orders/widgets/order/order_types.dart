import 'package:flutter/widgets.dart';

typedef OrderPresenter = ({
  String orderId,
  String userId,
  String summaryLabel,
  List<String> itemIds,
  bool isDeleteOrderButtonDisabled,
});

typedef OrderController = ({VoidCallback deleteOrderButtonPressed});
