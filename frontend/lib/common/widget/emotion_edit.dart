import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../features/emotions/emotion.dart';
import '../../features/emotions/emotion_color.dart';
import '../utils/utils.dart';

/// A widget for showing and selecting an emotion on click
class EmotionEdit extends StatelessWidget {
  /// Currently selected emotion
  final Emotion emotion;

  /// Handler after choosing an emotion
  final void Function(Emotion?) handler;

  /// A widget for showing and selecting an emotion on click
  const EmotionEdit({
    super.key,
    required this.emotion,
    required this.handler,
    required this.height,
  });

  /// Height of the image of the emotion
  final double height;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () async => {
          showDialog<Emotion>(
            context: context,
            builder: (context) => EmotionDialog(initialEmotion: emotion),
          ).then(handler),
        },
        child: EmotionImageText(
          emotion: emotion,
          height: height,
        ),
      );
}

/// Display an [Emotion] including Image and Text
class EmotionImageText extends StatelessWidget {
  /// The emotion to display
  final Emotion emotion;

  /// Display an Emotion including Image and Text
  const EmotionImageText({
    super.key,
    required this.emotion,
    required this.height,
    this.direction = AxisDirection.right,
  });

  /// Height of the image of the emotion
  final double height;

  /// Which Direction have rounded corners
  final AxisDirection direction;

  String _backSVGFileFromDirection() {
    switch (direction) {
      case AxisDirection.right:
        return 'assets/images/rect_right_curve_svg.svg';
      case AxisDirection.up:
        return 'assets/images/rect_top_curve_svg.svg';
      default:
        return 'assets/images/rect_right_curve_svg.svg';
    }
  }

  /// Ratio of text height to image height
  static const textRatio = 0.4;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(5),
        child: Container(
          constraints: BoxConstraints.tightFor(
            height: height + height * textRatio,
          ),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              SvgPicture.asset(
                _backSVGFileFromDirection(),
                color: emotion.color(),
                height: height + height * textRatio,
              ),
              Column(
                children: [
                  EmotionImage(
                    emotion: emotion,
                    height: height,
                  ),
                  Container(
                    padding: const EdgeInsets.all(5),
                    width: height,
                    height: height * textRatio,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        emotion.name,
                        style: context.bodySmall,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}

/// How to display just the emotions image
class EmotionImage extends StatelessWidget {
  /// How to display just the emotions image
  const EmotionImage({
    super.key,
    required this.emotion,
    required this.height,
  });

  /// The emotion to display
  final Emotion emotion;

  /// Height of the image of the emotion
  final double height;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(5),
        constraints: BoxConstraints.tight(Size(height, height)),
        child: SvgPicture.network(
          emotion.iconFullUrl(),
          width: height,
          color: context.colors.onSurface,
        ),
      );
}
