import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'emotion_model.g.dart';

@JsonSerializable()
@immutable
class Emotion {
  final String name;
  @JsonKey(name: 'icon_url')
  final String iconUrl;
  final String description;

  const Emotion({
    required this.name,
    required this.iconUrl,
    required this.description,
  });

  factory Emotion.fromJson(Map<String, dynamic> json) =>
      _$EmotionFromJson(json);

  Map<String, dynamic> toJson() => _$EmotionToJson(this);

  @override
  String toString() => json.encode(toJson());

  @override
  bool operator ==(Object other) => other is Emotion && name == other.name;

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
