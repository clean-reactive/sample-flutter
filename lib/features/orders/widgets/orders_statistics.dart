import 'package:flutter/material.dart';

import 'pill.dart';

/// Contract of the orders statistics unit.
///
/// It does two jobs. It fixes the parameters of the user interface unit, which
/// implements it — the parameter list cannot drift from the contract without
/// failing to compile. And it types the presenter that supplies those values,
/// so both ends of the read path are held to the same declaration.
///
/// It carries no observability of its own. How a presenter notices a change
/// and how the widget rebuilds are the lookup's concern, which leaves every
/// implementation free to satisfy this the way it likes.
abstract interface class OrdersStatisticsPresenter {
  String get usersCount;
  String get ordersCount;
  String get itemsCount;
  String get totalItemsQuantity;
}

/// Orders statistics unit.
///
/// The public entry point of the unit. It takes nothing from its parent — the
/// values it renders are obtained here, so a caller only places the widget.
class OrdersStatistics extends StatelessWidget {
  const OrdersStatistics({super.key});

  @override
  Widget build(BuildContext context) {
    const usersCount = '2';
    const ordersCount = '2';
    const itemsCount = '3';
    const totalItemsQuantity = '7';

    return const _UserInterface(
      usersCount: usersCount,
      ordersCount: ordersCount,
      itemsCount: itemsCount,
      totalItemsQuantity: totalItemsQuantity,
    );
  }
}

/// User interface unit of the orders statistics.
///
/// Primitives in, layout out. It implements `OrdersStatisticsPresenter`, so
/// its parameters are the contract rather than merely agreeing with it. It
/// takes no input from the user, so it has no controller.
class _UserInterface extends StatelessWidget
    implements OrdersStatisticsPresenter {
  const _UserInterface({
    required this.usersCount,
    required this.ordersCount,
    required this.itemsCount,
    required this.totalItemsQuantity,
  });

  @override
  final String usersCount;

  @override
  final String ordersCount;

  @override
  final String itemsCount;

  @override
  final String totalItemsQuantity;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        Pill(value: usersCount, label: 'users'),
        Pill(value: ordersCount, label: 'orders'),
        Pill(value: itemsCount, label: 'items'),
        Pill(value: totalItemsQuantity, label: 'qty'),
      ],
    );
  }
}
