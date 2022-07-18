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

  /// Amount of Joy
  final int joy;

  /// Amount of Sadness
  final int sadness;

  /// Amount of Anger
  final int anger;

  /// Amount of disgust
  final int disgust;

  /// Amount of surprise
  final int surprise;

  /// Amount of Fear
  final int fear;

  /// representation of an emotion
  const Emotion({
    required this.name,
    required this.iconUrl,
    required this.description,
    required this.joy,
    required this.sadness,
    required this.anger,
    required this.disgust,
    required this.surprise,
    required this.fear,
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
