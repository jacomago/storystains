import 'dart:math';

import 'package:flutter/material.dart';

import 'package:storystains/common/extensions.dart';

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
            size: 56,
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 12),
          child: Text(
            widget.text ?? 'Loading...',
            style: context.labelLarge,
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
            width: 16,
            height: 16,
            margin: EdgeInsets.only(
              right: 8,
            ),
            decoration: BoxDecoration(
                color: context.colors.primary,
                borderRadius: BorderRadius.circular(20)),
          ),
        ),
        AnimatedOpacity(
          opacity: animationRight.value,
          duration: const Duration(milliseconds: 100),
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
                color: context.colors.primary,
                borderRadius: BorderRadius.circular(20)),
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
      width: 750,
      padding: EdgeInsets.symmetric(vertical: 14),
      margin: EdgeInsets.only(bottom: 200),
      child: Column(
        children: [
          Text(
            'Story Stains',
            style: context.displayMedium,
          ),
          Text(
            'A place to share your feelings.',
            style: context.displaySmall!.copyWith(fontStyle: FontStyle.italic),
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
            margin: EdgeInsets.only(bottom: 70),
            child: Icon(
              Icons.error_rounded,
              size: 48,
              color: context.colors.primary,
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 40),
            child: Text(text),
          ),
          GestureDetector(
            onTap: () {
              callback();
            },
            child: Container(
              margin: EdgeInsets.only(bottom: 80),
              padding: EdgeInsets.symmetric(horizontal: 80, vertical: 20),
              decoration: BoxDecoration(
                  color: context.colors.onBackground,
                  border: Border.all(width: 1, color: context.colors.primary),
                  borderRadius: BorderRadius.circular(40)),
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
      width: 750,
      color: context.colors.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 70),
            child: Icon(
              Icons.error_rounded,
              size: 48,
              color: context.colors.primary,
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 40),
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
