import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../common/constant/app_config.dart';

part 'emotion_model.g.dart';

/// representation of an emotion
@JsonSerializable()
@immutable
class Emotion {
  /// Name of emotion
  final String name;

  /// url of icon to show (SVG)
  @JsonKey(name: 'icon_url')
  final String iconUrl;

  /// Description of emotion
  final String description;

  /// representation of an emotion
  const Emotion({
    required this.name,
    required this.iconUrl,
    required this.description,
  });

  /// base url for getting icons (remove the api from the end of base url)
  static String imagesBaseUrl =
      AppConfig.baseUrl.substring(0, AppConfig.baseUrl.length - 4);

  /// Full url of icon
  String iconFullUrl() => '$imagesBaseUrl$iconUrl';

  /// Get emotion from json
  factory Emotion.fromJson(Map<String, dynamic> json) =>
      _$EmotionFromJson(json);

  /// emotion to json
  Map<String, dynamic> toJson() => _$EmotionToJson(this);

  @override
  String toString() => json.encode(toJson());

  @override
  bool operator ==(Object other) => other is Emotion && name == other.name;

  @override
  int get hashCode => name.hashCode;
}

/// emotions from the api
@JsonSerializable()
class EmotionsResp {
  /// list of emotions
  List<Emotion> emotions;

  /// emotions from the api
  EmotionsResp({required this.emotions});

  /// Emotions from json
  factory EmotionsResp.fromJson(Map<String, dynamic> json) =>
      _$EmotionsRespFromJson(json);

  /// Emotions to json
  Map<String, dynamic> toJson() => _$EmotionsRespToJson(this);
}
