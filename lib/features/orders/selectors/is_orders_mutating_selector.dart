import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/orders_repository.dart';

final isOrdersMutatingSelector = Provider<bool>(
  (ref) => ref.watch(
    ordersRepositoryWritesInFlightProvider.select((count) => count > 0),
  ),
);
