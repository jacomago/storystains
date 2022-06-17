import 'package:flutter/material.dart';
import 'package:storystains/common/widget/emotion_image.dart';
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
      child: Padding(
        padding: const EdgeInsets.all(20),
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
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
