import 'package:flutter/material.dart';
import 'package:storystains/model/entity/review.dart';
import 'package:storystains/pages/account.dart';
import 'package:storystains/pages/home.dart';
import 'package:storystains/pages/login_register.dart';
import 'package:storystains/pages/review_detail.dart';

import '../pages/review_edit.dart';
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

Route routes(RouteSettings settings) {
  switch (settings.name) {
    case Routes.home:
      return _page(const Home(), settings);
    case Routes.login:
      return _page(LoginOrRegisterPage(), settings);
    case Routes.account:
      return _page(const AccountPage(), settings);
    case Routes.reviewDetail:
      return _page(const ReviewDetail(), settings);
    case Routes.reviewEdit:
      return _page(const EditReview<Review>(), settings);
    case Routes.reviewNew:
      return _page(const CreateReview(), settings);
    case Routes.root:
    default:
      return _page(const Home(), settings);
  }
}

MaterialPageRoute _page(page, RouteSettings settings) {
  return MaterialPageRoute(builder: (_) => page, settings: settings);
}
