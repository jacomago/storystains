import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/auth/auth.dart';
import '../../features/user/user.dart';
import '../../pages/user_profile.dart';
import '../../routes/routes.dart';
import '../utils/utils.dart';

/// Option for navbar of selected item
enum NavOption {
  /// Home page
  home,

  /// Reviews
  reviews,

  /// Login or Account
  account,

  /// Profile
  profile
}

/// navigation bar for scaffold
class NavBar extends StatelessWidget {
  /// constructor for navbar
  const NavBar({Key? key, this.currentNav}) : super(key: key);

  /// Index of selected navigation item
  final NavOption? currentNav;

  Icon _buildAuthIcon(BuildContext context) {
    var authState = Provider.of<AuthState>(context);

    return authState.isAuthenticated
        ? const Icon(Icons.person_pin_sharp)
        : const Icon(Icons.login);
  }

  void _authAction(BuildContext context) {
    var authState = Provider.of<AuthState>(context);

    authState.isAuthenticated
        ? context.pushNamed(Routes.account)
        : context.pushNamed(Routes.login);
  }

  void _myReviewsAction(BuildContext context) {
    var authState = Provider.of<AuthState>(context);

    authState.isAuthenticated
        ? Navigator.of(context).push(
            authState.userProfile!.route(
              Routes.userProfile,
              (u) => UserProfilePage(
                user: u,
              ),
            ),
          )
        : context.pushNamed(Routes.reviews);
  }

  void _onTap(int selected, BuildContext context) {
    switch (selected) {
      case 0:
        context.pushNamed(Routes.home);
        break;
      case 1:
        context.pushNamed(Routes.reviews);
        break;
      case 2:
        _authAction(context);
        break;
      case 3:
        _myReviewsAction(context);
        break;
      default:
        context.pushNamed(Routes.home);
    }
  }

  static const _navMap = {
    NavOption.home: 0,
    NavOption.reviews: 1,
    NavOption.account: 2,
    NavOption.profile: 3,
  };

  int _currentIndex(NavOption? option) => _navMap[option] ?? 0;

  @override
  Widget build(BuildContext context) => BottomNavigationBar(
        unselectedLabelStyle:
            context.button!.copyWith(decoration: TextDecoration.underline),
        selectedLabelStyle: context.button,
        onTap: ((value) => _onTap(value, context)),
        currentIndex: _currentIndex(currentNav),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: context.locale.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.search),
            label: context.locale.search,
          ),
          BottomNavigationBarItem(
            icon: _buildAuthIcon(context),
            label: context.locale.account,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.list),
            label: context.locale.myReviews,
          ),
        ],
      );
}
