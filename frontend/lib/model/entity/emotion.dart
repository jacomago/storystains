import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'emotion.g.dart';

@JsonSerializable()
class Emotion {
  String name;
  String icon_url;
  String description;

  Emotion({
    required this.name,
    required this.icon_url,
    required this.description,
  });

  factory Emotion.fromJson(Map<String, dynamic> json) =>
      _$EmotionFromJson(json);

  Map<String, dynamic> toJson() => _$EmotionToJson(this);

  @override
  String toString() {
    return json.encode(toJson());
  }

  static fromName(String s) {
    
  }
}
