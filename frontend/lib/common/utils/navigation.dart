import 'package:flutter/widgets.dart';

extension BuildContextNavigation on BuildContext {
  Future<T?> push<T extends Object?>(String routeName, {Object? arguments}) =>
      Navigator.of(this).pushNamed(
        routeName,
        arguments: arguments,
      );

  Future<T?> replace<T extends Object?, TO extends Object?>(
    String routeName, {
    Object? arguments,
  }) =>
      Navigator.of(this).pushReplacementNamed(
        routeName,
        arguments: arguments,
      );

  void pop<T extends Object?>([T? result]) {
    Navigator.of(this).pop(result);
  }
}
