import 'package:flutter/material.dart';

/// Timeline widget
class Timeline extends StatelessWidget {
  /// time line widget
  const Timeline({
    Key? key,
    required this.children,
    this.indicators,
    this.isLeftAligned = true,
    this.itemGap = 12.0,
    this.gutterSpacing = 4.0,
    this.padding = const EdgeInsets.all(8),
    this.controller,
    this.lineColor = Colors.grey,
    this.physics,
    this.shrinkWrap = true,
    this.primary = false,
    this.reverse = false,
    this.indicatorSize = 30.0,
    this.lineGap = 4.0,
    this.indicatorColor = Colors.blue,
    this.indicatorStyle = PaintingStyle.fill,
    this.strokeCap = StrokeCap.butt,
    this.strokeWidth = 2.0,
    this.style = PaintingStyle.stroke,
  })  : itemCount = children.length,
        assert(itemGap >= 0),
        assert(lineGap >= 0),
        assert(indicators == null || children.length == indicators.length),
        super(key: key);

  /// The widgets on the left
  final List<Widget> children;

  /// gap between children
  final double itemGap;

  /// spacing from indicators to children
  final double gutterSpacing;

  /// indicators
  final List<Widget>? indicators;

  /// Left alignted
  final bool isLeftAligned;

  /// Any extra padding
  final EdgeInsets padding;

  /// Scrolling controller
  final ScrollController? controller;

  /// NUmber of items
  final int itemCount;

  ///Physics for scrolling
  final ScrollPhysics? physics;

  /// Whether to srhink wrap it all
  final bool shrinkWrap;

  /// list view option
  final bool primary;

  /// Whether to reverse the list
  final bool reverse;

  /// color of line between indicators
  final Color lineColor;

  /// gap between lines and indicators
  final double lineGap;

  /// size of indicators
  final double indicatorSize;

  /// color of indicator
  final Color indicatorColor;

  /// How to paint indicator
  final PaintingStyle indicatorStyle;

  /// Stroke cap
  final StrokeCap strokeCap;

  /// Width of stroke
  final double strokeWidth;

  /// stroke painting style
  final PaintingStyle style;

  @override
  Widget build(BuildContext context) => ListView.separated(
        padding: padding,
        separatorBuilder: (_, __) => SizedBox(height: itemGap),
        physics: physics,
        shrinkWrap: shrinkWrap,
        itemCount: itemCount,
        controller: controller,
        reverse: reverse,
        primary: primary,
        itemBuilder: (context, index) {
          final child = children[index];

          Widget? indicator;
          if (indicators != null) {
            indicator = indicators![index];
          }

          final isFirst = index == 0;
          final isLast = index == itemCount - 1;

          final timelineTile = <Widget>[
            CustomPaint(
              foregroundPainter: _TimelinePainter(
                hideDefaultIndicator: indicator != null,
                lineColor: lineColor,
                indicatorColor: indicatorColor,
                indicatorSize: indicatorSize,
                indicatorStyle: indicatorStyle,
                isFirst: isFirst,
                isLast: isLast,
                lineGap: lineGap,
                strokeCap: strokeCap,
                strokeWidth: strokeWidth,
                style: style,
                itemGap: itemGap,
              ),
              child: SizedBox(
                height: double.infinity,
                width: indicatorSize,
                child: indicator,
              ),
            ),
            SizedBox(width: gutterSpacing),
            Expanded(child: child),
          ];

          return IntrinsicHeight(
            child: Row(
              children:
                  isLeftAligned ? timelineTile : timelineTile.reversed.toList(),
            ),
          );
        },
      );
}

class _TimelinePainter extends CustomPainter {
  _TimelinePainter({
    required this.hideDefaultIndicator,
    required this.indicatorColor,
    required this.indicatorStyle,
    required this.indicatorSize,
    required this.lineGap,
    required this.strokeCap,
    required this.strokeWidth,
    required this.style,
    required this.lineColor,
    required this.isFirst,
    required this.isLast,
    required this.itemGap,
  })  : linePaint = Paint()
          ..color = lineColor
          ..strokeCap = strokeCap
          ..strokeWidth = strokeWidth
          ..style = style,
        circlePaint = Paint()
          ..color = indicatorColor
          ..style = indicatorStyle;

  final bool hideDefaultIndicator;
  final Color indicatorColor;
  final PaintingStyle indicatorStyle;
  final double indicatorSize;
  final double lineGap;
  final StrokeCap strokeCap;
  final double strokeWidth;
  final PaintingStyle style;
  final Color lineColor;
  final Paint linePaint;
  final Paint circlePaint;
  final bool isFirst;
  final bool isLast;
  final double itemGap;

  @override
  void paint(Canvas canvas, Size size) {
    final indicatorRadius = indicatorSize / 2;
    final halfItemGap = itemGap / 2;
    final indicatorMargin = indicatorRadius + lineGap;

    final top = size.topLeft(Offset(indicatorRadius, 0.0 - halfItemGap));
    final centerTop = size.centerLeft(
      Offset(indicatorRadius, -indicatorMargin),
    );

    final bottom = size.bottomLeft(Offset(indicatorRadius, 0.0 + halfItemGap));
    final centerBottom = size.centerLeft(
      Offset(indicatorRadius, indicatorMargin),
    );

    if (!isFirst) canvas.drawLine(top, centerTop, linePaint);
    if (!isLast) canvas.drawLine(centerBottom, bottom, linePaint);

    if (!hideDefaultIndicator) {
      final offsetCenter = size.centerLeft(Offset(indicatorRadius, 0));

      canvas.drawCircle(offsetCenter, indicatorRadius, circlePaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
