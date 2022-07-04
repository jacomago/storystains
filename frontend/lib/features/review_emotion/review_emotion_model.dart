import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import '../emotions/emotion_model.dart';

part 'review_emotion_model.g.dart';

/// Review emotion main model
@JsonSerializable()
@immutable
class ReviewEmotion {
  final String notes;
  final Emotion emotion;
  final int position;

  const ReviewEmotion({
    required this.notes,
    required this.emotion,
    required this.position,
  });

  factory ReviewEmotion.fromJson(Map<String, dynamic> json) =>
      _$ReviewEmotionFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewEmotionToJson(this);

  @override
  String toString() => json.encode(toJson());

  @override
  bool operator ==(Object other) =>
      other is ReviewEmotion &&
      notes == other.notes &&
      emotion == other.emotion &&
      position == other.position;

  @override
  int get hashCode => notes.hashCode + emotion.hashCode + position.hashCode;
}

/// request representation of [ReviewEmotion]
@JsonSerializable()
class CreateReviewEmotion {
  /// request representation of [ReviewEmotion]
  @JsonKey(name: 'review_emotion')
  NewReviewEmotion reviewEmotion;

  /// request representation of [ReviewEmotion]
  CreateReviewEmotion({required this.reviewEmotion});

  /// request representation of [ReviewEmotion] from json
  factory CreateReviewEmotion.fromJson(Map<String, dynamic> json) =>
      _$CreateReviewEmotionFromJson(json);

  /// request representation of [ReviewEmotion] to json
  Map<String, dynamic> toJson() => _$CreateReviewEmotionToJson(this);
}

/// request representation of [ReviewEmotion]
@JsonSerializable()
class NewReviewEmotion {
  /// request representation of [Emotion]
  String emotion;

  /// request representation of [ReviewEmotion.position]
  int position;

  /// request representation of [ReviewEmotion.notes]
  String notes;

  /// request representation of [ReviewEmotion]
  NewReviewEmotion({
    required this.emotion,
    required this.notes,
    required this.position,
  });

  /// request representation of [ReviewEmotion] from json
  factory NewReviewEmotion.fromJson(Map<String, dynamic> json) =>
      _$NewReviewEmotionFromJson(json);

  /// request representation of [ReviewEmotion] to json
  Map<String, dynamic> toJson() => _$NewReviewEmotionToJson(this);
}

/// response representation of [ReviewEmotion]
@JsonSerializable()
class ReviewEmotionResp {
  @JsonKey(name: 'review_emotion')
  ReviewEmotion reviewEmotion;

  /// response representation of [ReviewEmotion]
  ReviewEmotionResp({required this.reviewEmotion});

  /// response representation of [ReviewEmotion] from json
  factory ReviewEmotionResp.fromJson(Map<String, dynamic> json) =>
      _$ReviewEmotionRespFromJson(json);

  /// response representation of [ReviewEmotion] to json
  Map<String, dynamic> toJson() => _$ReviewEmotionRespToJson(this);
}
