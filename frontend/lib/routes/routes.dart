// ignore_for_file: avoid_classes_with_only_static_members

import 'package:flutter/material.dart';
import '../features/review/review.dart';
import '../pages/account.dart';
import '../pages/home.dart';
import '../pages/login_register.dart';
import '../pages/not_found.dart';
import '../pages/review_detail.dart';
import '../pages/review_new.dart';

class Routes {
  static const String root = '/';
  static const String home = '/home';
  static const String login = '/login';
  static const String account = '/account';
  static const String reviews = '/reviews';
  static const String reviewDetail = '/reviewDetail';
  static const String reviewEdit = '/reviewEdit';
  static const String reviewNew = '/reviewNew';
}

typedef PathWidgetBuilder = Widget Function(BuildContext, List<String>?);

class Path {
  const Path(
    this.pattern,
    this.groupNames,
    this.builder,
  );

  /// A RegEx string for route matching.
  final String pattern;

  /// Names used in the pattern for matching.
  final List<String> groupNames;

  /// The builder for the associated pattern route. The first argument is the
  /// [BuildContext] and the second argument a RegEx match if that is included
  /// in the pattern.
  ///
  /// ```dart
  /// Path(
  ///   'r'^/demo/([\w-]+)$',
  ///   (context, matches) => Page(argument: match),
  /// )
  /// ```
  final PathWidgetBuilder builder;
}

class RouteConfiguration {
  /// List of [Path] to for route matching. When a named route is pushed with
  /// [Navigator.pushNamed], the route name is matched with the [Path.pattern]
  /// in the list below. As soon as there is a match, the associated builder
  /// will be returned. This means that the paths higher up in the list will
  /// take priority.
  static List<Path> paths = [
    Path(
      r'^' + Routes.reviewDetail + r'/(?<username>[\w-]+)/(?<slug>[\w-]+)$',
      ['username', 'slug'],
      (context, matchs) => ReviewDetail(
        path: matchs == null
            ? null
            : ReviewRoutePath(
                matchs[1],
                matchs[0],
              ),
      ),
    ),
    Path(
      r'^' + Routes.reviewNew,
      [],
      (context, matchs) => const ReviewNew(),
    ),
    Path(
      r'^' + Routes.home,
      [],
      (context, matchs) => const Home(),
    ),
    Path(
      r'^' + Routes.login,
      [],
      (context, matchs) => LoginOrRegisterPage(),
    ),
    Path(
      r'^' + Routes.account,
      [],
      (context, matchs) => const AccountPage(),
    ),
    Path(
      r'^' + Routes.root,
      [],
      (context, matchs) => const Home(),
    ),
  ];

  /// The route generator callback used when the app is navigated to a named
  /// route. Set it on the [MaterialApp.onGenerateRoute] or
  /// [WidgetsApp.onGenerateRoute] to make use of the [paths] for route
  /// matching.
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    for (final path in paths) {
      final regExpPattern = RegExp(path.pattern);
      if (regExpPattern.hasMatch(settings.name!)) {
        final firstMatch = regExpPattern.firstMatch(settings.name!)!;
        final matchs = (firstMatch.groupCount > 0)
            ? path.groupNames.map((e) => firstMatch.namedGroup(e)!).toList()
            : null;

        return MaterialPageRoute<void>(
          builder: (context) => path.builder(context, matchs),
          settings: settings,
        );
      }
    }

    return MaterialPageRoute<void>(
      builder: (context) => const NotFoundPage(),
      settings: settings,
    );
  }
}
