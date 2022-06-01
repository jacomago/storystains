import 'package:flutter/material.dart';

import 'package:storystains/screens/home.dart';
import 'package:storystains/screens/login.dart';
import 'package:storystains/screens/splash.dart';
import 'package:storystains/screens/users.dart';

import '../screens/reviews.dart';

class Routes {
  static const String root = '/';
  static const String home = '/home';
  static const String login = '/login';
  static const String users = '/users';
  static const String reviews = '/reviews';
}

Route routes(RouteSettings settings) {
  switch (settings.name) {
    case Routes.home:
      return _page(const Home(), settings);
    case Routes.login:
      return _page(Login(), settings);
    case Routes.users:
      return _page(const Users(), settings);
    case Routes.reviews:
      return _page(const Reviews(), settings);
    case Routes.root:
    default:
      return _page(const Splash(), settings);
  }
}

MaterialPageRoute _page(page, RouteSettings settings) {
  return MaterialPageRoute(builder: (_) => page, settings: settings);
}