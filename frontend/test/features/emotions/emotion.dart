import 'package:storystains/features/emotions/emotion_model.dart';

Emotion testEmotion({String? name}) => Emotion(
      name: name ?? 'name',
      iconUrl: '/iconUrl',
      description: 'description',
      joy: 0,
      sadness: 0,
      anger: 0,
      disgust: 0,
      surprise: 0,
      fear: 0,
    );
