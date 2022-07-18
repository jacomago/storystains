import 'package:flutter/material.dart';

import '../../common/constant/app_theme.dart';
import 'emotion_model.dart';

/// Background color for an [Emotion]
extension EmotionColor on Emotion {
  /// Resulting color
  Color color() {
    final properties = {
      EmotionColors.joy: joy,
      EmotionColors.anger: anger,
      EmotionColors.surprise: surprise,
      EmotionColors.disgust: disgust,
      EmotionColors.sadness: sadness,
      EmotionColors.fear: fear,
    };
    for (var k in properties.entries) {
      if (properties.entries
          .where(
            (element) => k.key != element.key && element.value > k.value,
          )
          .isEmpty) {
        return k.key.withAlpha(k.value * 33);
      }
    }
    var pair = properties.entries.where((element) => element.value > 0);

    return Color.lerp(pair.first.key, pair.last.key, 0.5)!.withAlpha(100);
  }
}
