import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() {
  // Composition root. Every unit that reads or writes shared state does so
  // through a provider, and this is the scope they are read from.
  //
  // It overrides nothing: `ordersGatewayProvider` resolves through
  // `makeOrdersService`, so the application runs on its defaults and a test is
  // the only thing that needs to substitute anything.
  runApp(const ProviderScope(child: App()));
}
