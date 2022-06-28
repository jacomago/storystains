import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:storystains/common/utils/utils.dart';

import 'package:storystains/features/emotions/emotion.dart';

class EmotionEdit extends StatelessWidget {
  final Emotion emotion;
  final Function(Emotion?) handler;

  const EmotionEdit({
    Key? key,
    required this.emotion,
    required this.handler,
    this.height,
    this.width,
  }) : super(key: key);
  final double? height;
  final double? width;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async => {
        showDialog<Emotion>(
          context: context,
          builder: (context) {
            return EmotionDialog(initialEmotion: emotion);
          },
        ).then(handler),
      },
      child: EmotionImageText(
        emotion: emotion,
        height: height,
        width: width,
      ),
    );
  }
}

class EmotionImageText extends StatelessWidget {
  final Emotion emotion;
  const EmotionImageText({
    Key? key,
    required this.emotion,
    this.height,
    this.width,
  }) : super(key: key);

  final double? height;
  final double? width;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: SizedBox(
        width: width,
        height: height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: EmotionImage(
                emotion: emotion,
                width: width,
                height: height,
              ),
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
}

class EmotionImage extends StatelessWidget {
  const EmotionImage({
    Key? key,
    required this.emotion,
    this.width,
    this.height,
  }) : super(key: key);
  final Emotion emotion;
  final double? width;
  final double? height;
  @override
  Widget build(BuildContext context) {
    return SvgPicture.network(
      EmotionsState.iconFullUrl(emotion),
      width: width,
      height: height,
      color: context.colors.onPrimaryContainer,
    );
  }
}
