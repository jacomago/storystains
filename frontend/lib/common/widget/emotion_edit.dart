import 'package:flutter/material.dart';
import 'package:storystains/common/widget/emotion_image_text.dart';
import 'package:storystains/model/entity/emotion.dart';

import 'emotion_picker.dart';

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
