import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:storystains/common/extensions.dart';

class PageBar extends PreferredSize {
  final BuildContext context;
  final String? title;
  final Color? backgroundColor;
  final bool hideBack;
  final Widget? leftMenu;
  final Widget? middleMenu;
  final Widget? rightMenu;

  PageBar({
    Key? key,
    required this.context,
    this.title,
    this.backgroundColor,
    this.hideBack = false,
    this.leftMenu,
    this.middleMenu,
    this.rightMenu,
  }) : super(
          key: key,
          preferredSize: Size(MediaQuery.of(context).size.width, 88),
          child: Container(
            height: MediaQuery.of(context).padding.top + 88,
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top, left: 24, right: 24),
            decoration: BoxDecoration(
              color: backgroundColor ?? context.colors.background,
            ),
            child: Flex(
              direction: Axis.horizontal,
              children: [
                Flexible(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: hideBack
                        ? const SizedBox.shrink()
                        : leftMenu ??
                            GestureDetector(
                              onTap: () => Get.back(),
                              child: SizedBox(
                                width: 48,
                                height: 48,
                                child: Icon(
                                  Icons.arrow_back_rounded,
                                  size: 48,
                                  color: context.colors.primary,
                                ),
                              ),
                            ),
                  ),
                ),
                Flexible(
                  flex: 3,
                  child: Center(
                    child: middleMenu ??
                        Text(
                          title ?? '',
                          style: context.headlineSmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: rightMenu,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
}
