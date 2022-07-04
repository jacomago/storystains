import 'package:storystains/features/emotions/emotion_model.dart';
import 'package:storystains/features/review_emotion/review_emotion_model.dart';

import '../emotions/emotion.dart';

ReviewEmotion testReviewEmotion({
  int? position,
  Emotion? emotion,
  String? notes,
}) =>
    ReviewEmotion(
      notes: notes ?? 'notes',
      emotion: emotion ?? testEmotion(),
      position: position ?? 0,
    );
