import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';

import '../common/widget/widget.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: const StainsAppBar(
          title: AppBarTitle('404'),
        ),
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
                Text(AppLocalizations.of(context)!.pageNotFound),
              ],
            ),
          ),
        ),
      );
}
