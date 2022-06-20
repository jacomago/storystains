import 'package:storystains/model/entity/emotion.dart';
import 'package:storystains/model/entity/review_emotion.dart';

import 'emotion.dart';

ReviewEmotion testReviewEmotion({
  int? position,
  Emotion? emotion,
  String? notes,
}) =>
    ReviewEmotion(
      notes: notes ?? "notes",
      emotion: emotion ?? testEmotion(),
      position: position ?? 0,
    );
