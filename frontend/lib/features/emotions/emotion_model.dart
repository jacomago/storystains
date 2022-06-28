import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'emotion_model.g.dart';

@JsonSerializable()
class Emotion {
  String name;
  @JsonKey(name: 'icon_url')
  String iconUrl;
  String description;

  Emotion({
    required this.name,
    required this.iconUrl,
    required this.description,
  });

  factory Emotion.fromJson(Map<String, dynamic> json) =>
      _$EmotionFromJson(json);

  Map<String, dynamic> toJson() => _$EmotionToJson(this);

  @override
  String toString() {
    return json.encode(toJson());
  }

  @override
  bool operator ==(Object other) {
    return other is Emotion && name == other.name;
  }

  @override
  int get hashCode => name.hashCode;
}

@JsonSerializable()
class EmotionsResp {
  List<Emotion> emotions;

  EmotionsResp({required this.emotions});

  factory EmotionsResp.fromJson(Map<String, dynamic> json) =>
      _$EmotionsRespFromJson(json);

  Map<String, dynamic> toJson() => _$EmotionsRespToJson(this);
}