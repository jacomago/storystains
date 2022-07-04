import 'package:flutter/material.dart';

/// Helper method to create a [SnackBar] on a [BuildContext]
extension BuildContextSnackbar on BuildContext {
  /// Helper method to create a [SnackBar] on a [BuildContext]
  void snackbar(String message) {
    ScaffoldMessenger.of(this).clearSnackBars();
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }
}
