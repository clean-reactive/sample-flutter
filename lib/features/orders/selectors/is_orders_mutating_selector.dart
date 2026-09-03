import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/orders_repository.dart';

/// Whether any write to the orders is in flight.
///
/// The feature-wide counterpart to the per-order and per-item selectors: those
/// answer for one button, this answers for the feature's status.
final isOrdersMutatingSelector = Provider<bool>(
  (ref) => ref.watch(writesInFlight.select((count) => count > 0)),
);
