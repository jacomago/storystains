import 'package:storystains/model/entity/emotion.dart';

Emotion testEmotion([String? name]) => Emotion(
      name: name ?? "name",
      iconUrl: "/iconUrl",
      description: "description",
    );
