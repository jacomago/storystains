import 'package:get/get.dart';
import 'package:storystains/pages/review_detail/binding.dart';
import 'package:storystains/pages/review_detail/view.dart';
import 'package:storystains/pages/review_edit/binding.dart';
import 'package:storystains/pages/review_edit/view.dart';
import 'package:storystains/pages/review_post/binding.dart';
import 'package:storystains/pages/review_post/view.dart';

import 'home/binding.dart';
import 'home/view.dart';
import 'login_or_register/binding.dart';
import 'login_or_register/view.dart';

abstract class Pages {
  static const home = '/home';
  static const loginOrRegister = '/loginOrRegister';
  static const reviewDetail = '/reviewDetail';
  static const newReview = '/newReview';
  static const editReview = '/editReview';

  static final List<GetPage> all = [
    GetPage(
      name: Pages.home,
      page: () => const HomePage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Pages.loginOrRegister,
      page: () => const LoginOrRegisterPage(),
      binding: LoginOrRegisterBinding(),
    ),
    GetPage(
      name: Pages.reviewDetail,
      page: () => ReviewDetailPage(),
      binding: ReviewDetailBinding(),
    ),
    GetPage(
      name: Pages.newReview,
      page: () => const ReviewPostPage(),
      binding: ReviewPostBinding(),
    ),
    GetPage(
      name: Pages.editReview,
      page: () => ReviewEditPage(),
      binding: ReviewEditBinding(),
    ),
  ];
}
