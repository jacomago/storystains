import 'package:flutter/widgets.dart';

/// Basic helper functions for [Navigator].of(context).something
extension BuildContextNavigation on BuildContext {
  /// Helper for Navigator.of(this).pushNamed
  Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) =>
      Navigator.of(this).pushNamed(
        routeName,
        arguments: arguments,
      );

  /// Helper for Navigator.of(this).pushNamed
  Future<T?> push<T extends Object?>(Route<T> route) =>
      Navigator.of(this).push(route);

  /// Helper for [Navigator].of(this).pushReplacementNamed
  Future<T?> replace<T extends Object?, TO extends Object?>(
    String routeName, {
    Object? arguments,
  }) =>
      Navigator.of(this).pushReplacementNamed(
        routeName,
        arguments: arguments,
      );

  /// Helper for [Navigator].of(this).pop
  void pop<T extends Object?>([T? result]) {
    Navigator.of(this).pop(result);
  }
}
