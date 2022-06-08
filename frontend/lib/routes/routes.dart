import 'package:flutter/material.dart';
import 'package:storystains/pages/home/view.dart';
import 'package:storystains/pages/login_or_register/view.dart';
import 'package:storystains/pages/review_detail/view.dart';

import '../pages/review_edit/view.dart';

class Routes {
  static const String root = '/';
  static const String home = '/home';
  static const String login = '/login';
  static const String reviews = '/reviews';
  static const String reviewDetail = '/reviewDetail';
  static const String reviewEdit = '/reviewEdit';
  static const String reviewNew = '/reviewNew';
}

Route routes(RouteSettings settings) {
  switch (settings.name) {
    case Routes.home:
      return _page(HomePage(), settings);
    case Routes.login:
      return _page(LoginOrRegisterPage(), settings);
    case Routes.reviewDetail:
      return _page(ReviewDetailPage(), settings);
    case Routes.reviewEdit:
      return _page(const EditReview(), settings);
    case Routes.reviewNew:
      return _page(const CreateReview(), settings);
    case Routes.root:
    default:
      return _page(HomePage(), settings);
  }
}

MaterialPageRoute _page(page, RouteSettings settings) {
  return MaterialPageRoute(builder: (_) => page, settings: settings);
}
