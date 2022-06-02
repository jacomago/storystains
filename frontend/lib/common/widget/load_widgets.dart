import 'dart:math';

import 'package:flutter/material.dart';

import 'package:storystains/common/extensions.dart';
import '../constant/app_size.dart';

class LoadingView extends StatefulWidget {
  final String? text;

  const LoadingView({Key? key, this.text}) : super(key: key);

  @override
  _LoadingView createState() => _LoadingView();
}

class _LoadingView extends State<LoadingView>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation animation;

  @override
  initState() {
    super.initState();
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    animation = Tween(begin: pi, end: -pi).animate(controller)
      ..addListener(() {
        if (mounted) setState(() {});
      });
    controller.repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Transform.rotate(
          angle: animation.value,
          child: Icon(
            Icons.sync_rounded,
            color: context.colors.primary,
            size: AppSize.w_56,
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: AppSize.w_12),
          child: Text(
            widget.text ?? 'Loading...',
            style: TextStyle(fontSize: AppSize.s_24),
          ),
        ),
      ],
    );
  }
}

class RefreshLoadingView extends StatefulWidget {
  const RefreshLoadingView({Key? key}) : super(key: key);

  @override
  _RefreshLoadingView createState() => _RefreshLoadingView();
}

class _RefreshLoadingView extends State<RefreshLoadingView>
    with TickerProviderStateMixin {
  late AnimationController controllerLeft;
  late AnimationController controllerRight;
  late Animation animationLeft;
  late Animation animationRight;

  @override
  initState() {
    super.initState();
    controllerLeft =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    animationLeft = Tween(begin: 0.2, end: 1.0).animate(controllerLeft)
      ..addListener(() {
        if (mounted) setState(() {});
      });
    controllerLeft.repeat();
    controllerRight =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    animationRight = Tween(begin: 1.0, end: 0.2).animate(controllerRight)
      ..addListener(() {
        if (mounted) setState(() {});
      });
    controllerRight.repeat();
  }

  @override
  void dispose() {
    controllerLeft.dispose();
    controllerRight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedOpacity(
          opacity: animationLeft.value,
          duration: const Duration(milliseconds: 100),
          child: Container(
            width: AppSize.w_16,
            height: AppSize.w_16,
            margin: EdgeInsets.only(
              right: AppSize.w_8,
            ),
            decoration: BoxDecoration(
                color: context.colors.primary,
                borderRadius: BorderRadius.all(Radius.circular(AppSize.r_20))),
          ),
        ),
        AnimatedOpacity(
          opacity: animationRight.value,
          duration: const Duration(milliseconds: 100),
          child: Container(
            width: AppSize.w_16,
            height: AppSize.w_16,
            decoration: BoxDecoration(
                color: context.colors.primary,
                borderRadius: BorderRadius.all(Radius.circular(AppSize.r_20))),
          ),
        ),
      ],
    );
  }
}

class LoadFooter extends StatelessWidget {
  const LoadFooter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSize.w_750,
      padding: EdgeInsets.symmetric(vertical: AppSize.w_14),
      margin: EdgeInsets.only(bottom: AppSize.w_200),
      child: Column(
        children: [
          Text(
            'Story Stains',
            style: TextStyle(
              color: context.colors.primary,
              fontSize: AppSize.s_28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'A place to share your feelings.',
            style: TextStyle(
                color: context.colors.primary,
                fontSize: AppSize.s_16,
                fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

class LoadError extends StatelessWidget {
  final String text;
  final Function callback;

  const LoadError({Key? key, required this.text, required this.callback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: AppSize.w_70),
            child: Icon(
              Icons.error_rounded,
              size: AppSize.w_48,
              color: context.colors.primary,
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: AppSize.w_40),
            child: Text(text),
          ),
          GestureDetector(
            onTap: () {
              callback();
            },
            child: Container(
              margin: EdgeInsets.only(bottom: AppSize.w_80),
              padding: EdgeInsets.symmetric(
                  horizontal: AppSize.w_80, vertical: AppSize.w_20),
              decoration: BoxDecoration(
                  color: context.colors.onBackground,
                  border: Border.all(
                      width: AppSize.w_1, color: context.colors.primary),
                  borderRadius:
                      BorderRadius.all(Radius.circular(AppSize.r_40))),
              child: Text(
                'Retry',
                style: TextStyle(color: context.colors.error),
              ),
            ),
          ),
          const LoadFooter()
        ],
      ),
    );
  }
}

class LoadEmpty extends StatelessWidget {
  const LoadEmpty({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSize.w_750,
      color: context.colors.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: AppSize.w_70),
            child: Icon(
              Icons.error_rounded,
              size: AppSize.w_48,
              color: context.colors.primary,
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: AppSize.w_40),
            child: const Text(
              'No Data!',
              style: TextStyle(),
            ),
          ),
          const LoadFooter()
        ],
      ),
    );
  }
}
