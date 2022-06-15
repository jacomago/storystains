import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'emotion.g.dart';

@JsonSerializable()
class Emotion {
  String name;
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

  static fromName(String s) {}
}
