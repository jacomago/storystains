import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../common/utils/utils.dart';
import '../common/widget/widget.dart';
import '../routes/routes.dart';

/// page if not found by url
class NotFoundPage extends StatelessWidget {
  /// page if not found by url
  const NotFoundPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: const StainsAppBar(
          title: AppBarTitle('404'),
        ),
        bottomNavigationBar: const NavBar(),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: SvgPicture.asset(
                    'assets/logo/logo.svg',
                    height: 110,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  context.locale.pageNotFound,
                  style: context.titleLarge,
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () => context.pushNamed(Routes.home),
                  child: Text(
                    context.locale.goBackHome,
                    style: context.labelLarge,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
