import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A handle to the [ScaffoldMessengerState] the app places.
///
/// The messenger holds the toast state and renders it: it is the application
/// business entity, and the source of truth. The store holds only the handle,
/// which reaches it without a `BuildContext` — the widget that started a use
/// case may be gone by the time it finishes.
typedef ToastsPresentationEntity = GlobalKey<ScaffoldMessengerState>;

class ToastsPresentationStore extends Notifier<ToastsPresentationEntity> {
  @override
  ToastsPresentationEntity build() => GlobalKey<ScaffoldMessengerState>();

  /// Writes to the toast state in messages, so a use case never builds a
  /// widget.
  void show(String message) =>
      state.currentState?.showSnackBar(SnackBar(content: Text(message)));
}

final toastsPresentationStore =
    NotifierProvider<ToastsPresentationStore, ToastsPresentationEntity>(
      ToastsPresentationStore.new,
    );
