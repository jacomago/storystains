import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:storystains/common/widget/emotion_image.dart';
import 'package:storystains/model/entity/emotion.dart';

import 'emotion_picker.dart';

class EmotionEdit extends StatelessWidget {
  final Emotion emotion;
  final Function(Emotion?) handler;

  const EmotionEdit({Key? key, required this.emotion, required this.handler})
      : super(key: key);

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
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(children: [
          EmotionImage(emotion: emotion),
          Text(emotion.name),
        ]),
      ),
    );
  }
}
