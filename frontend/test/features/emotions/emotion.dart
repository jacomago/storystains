import 'package:storystains/features/emotions/emotion_model.dart';

Emotion testEmotion({String? name}) => Emotion(
      name: name ?? 'name',
      iconUrl: '/iconUrl',
      description: 'description',
    );
