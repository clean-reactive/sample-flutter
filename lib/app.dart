import 'package:flutter/material.dart';

import 'features/orders/orders.dart';

/// Application shell: theme and the frame the feature is placed in.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clean Reactive',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Padding(padding: EdgeInsets.all(24), child: Orders()),
          ),
        ),
      ),
    );
  }
}
