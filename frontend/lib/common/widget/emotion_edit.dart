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
    Key? key,
    required this.emotion,
    required this.handler,
    required this.height,
  }) : super(key: key);

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
    Key? key,
    required this.emotion,
    required this.height,
  }) : super(key: key);

  /// Height of the image of the emotion
  final double height;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(10),
        child: SizedBox(
          width: height,
          child: Column(
            children: [
              EmotionImage(
                emotion: emotion,
                height: height,
              ),
              Text(
                emotion.name,
                style: context.bodySmall,
                textAlign: TextAlign.center,
                overflow: TextOverflow.fade,
                maxLines: 1,
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
    Key? key,
    required this.emotion,
    required this.height,
  }) : super(key: key);

  /// The emotion to display
  final Emotion emotion;

  /// Height of the image of the emotion
  final double height;

  @override
  Widget build(BuildContext context) => Container(
        width: height,
        height: height,
        constraints: BoxConstraints.tight(Size(height, height)),
        color: emotion.color(),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: SvgPicture.network(
            emotion.iconFullUrl(),
            width: height,
            height: height,
            color: context.colors.onSurface,
          ),
        ),
      );
}
