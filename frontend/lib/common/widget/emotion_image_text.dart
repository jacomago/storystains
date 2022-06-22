import 'package:flutter/material.dart';
import 'package:storystains/common/utils/utils.dart';
import 'package:storystains/common/widget/emotion_image.dart';
import 'package:storystains/model/entity/emotion.dart';

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
