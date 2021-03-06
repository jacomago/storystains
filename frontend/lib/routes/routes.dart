// ignore_for_file: avoid_classes_with_only_static_members

import 'package:flutter/material.dart';
import '../features/mediums/medium_model.dart';
import '../features/review/review.dart';
import '../features/story/story.dart';
import '../features/user/user.dart';
import '../pages/account.dart';
import '../pages/home.dart';
import '../pages/login_register.dart';
import '../pages/not_found.dart';
import '../pages/review_detail.dart';
import '../pages/review_new.dart';
import '../pages/story_filter_page.dart';
import '../pages/user_profile.dart';

/// Routes in the app
class Routes {
  /// Root path
  static const String root = '/';

  /// Home path
  static const String home = '/home';

  /// Login path
  static const String login = '/login';

  /// Account path
  static const String account = '/account';

  /// User Profile path
  static const String userProfile = '/user';

  /// Reviews path
  static const String reviews = '/reviews';

  /// Path for creating a review
  static const String reviewNew = '/new_review';
}

/// Builder of a path for web urls
typedef PathWidgetBuilder = Widget Function(BuildContext, List<String>?);

/// Url path pattern for regex matching
class Path {
  /// Url path pattern for regex matching
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

/// Config of the app for routing
class RouteConfiguration {
  /// List of [Path] to for route matching. When a named route is pushed with
  /// [Navigator.pushNamed], the route name is matched with the [Path.pattern]
  /// in the list below. As soon as there is a match, the associated builder
  /// will be returned. This means that the paths higher up in the list will
  /// take priority.
  static List<Path> paths = [
    Path(
      r'^' + Routes.reviews + r'/(?<username>[\w-]+)/(?<slug>[\w-]+)$',
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
      r'^' + Routes.reviews + r'/\?(?<query>[\w=&]+)$',
      ['query'],
      (context, matchs) {
        final url = Uri.splitQueryString(matchs![0]);

        return StoryFilterPage(
          query: StoryQuery(
            title: url['title'] == null || url['title']!.isEmpty
                ? null
                : url['title'],
            creator: url['creator'] == null || url['creator']!.isEmpty
                ? null
                : url['creator'],
            medium: url.containsKey('medium') && url['medium']!.isNotEmpty
                ? Medium(name: url['medium']!)
                : null,
          ),
        );
      },
    ),
    Path(
      r'^' + Routes.userProfile + r'/(?<username>[\w-]+)',
      ['username'],
      (context, matchs) =>
          UserProfilePage(user: UserProfile(username: matchs![0])),
    ),
    Path(
      r'^' + Routes.reviewNew + r'$',
      [],
      (context, matchs) => const ReviewNew(),
    ),
    Path(
      r'^' + Routes.reviews,
      [],
      (context, matchs) => const StoryFilterPage(),
    ),
    Path(
      r'^' + Routes.home + r'$',
      [],
      (context, matchs) => const Home(),
    ),
    Path(
      r'^' + Routes.login + r'$',
      [],
      (context, matchs) => LoginOrRegisterPage(),
    ),
    Path(
      r'^' + Routes.account + r'$',
      [],
      (context, matchs) => const AccountPage(),
    ),
    Path(
      r'^' + Routes.root + r'$',
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
