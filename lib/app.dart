import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/orders/orders.dart';

/// Application shell: theme and the frame the feature is placed in.
class const App({super.key}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Clean Reactive',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      scaffoldMessengerKey: ref.watch(toastsPresentationStore),
      home: const Scaffold(
        body: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                child: Padding(padding: EdgeInsets.all(24), child: Orders()),
              ),
            ),
            OrdersToastDriver(),
          ],
        ),
      ),
    );
  }
}
