import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:storystains/features/emotions/emotion_model.dart';

part 'review_emotion_model.g.dart';

class ReviewEmotionArguement {
  final ReviewEmotion reviewEmotion;
  ReviewEmotionArguement(this.reviewEmotion);
}

@JsonSerializable()
class ReviewEmotion {
  String notes;
  Emotion emotion;
  int position;

  ReviewEmotion({
    required this.notes,
    required this.emotion,
    required this.position,
  });

  factory ReviewEmotion.fromJson(Map<String, dynamic> json) =>
      _$ReviewEmotionFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewEmotionToJson(this);

  @override
  String toString() {
    return json.encode(toJson());
  }

  @override
  bool operator ==(Object other) {
    return other is ReviewEmotion &&
        notes == other.notes &&
        emotion == other.emotion &&
        position == other.position;
  }

  @override
  int get hashCode => notes.hashCode + emotion.hashCode + position.hashCode;
}

@JsonSerializable()
class CreateReviewEmotion {
  @JsonKey(name: 'review_emotion')
  NewReviewEmotion reviewEmotion;

  CreateReviewEmotion({required this.reviewEmotion});

  factory CreateReviewEmotion.fromJson(Map<String, dynamic> json) =>
      _$CreateReviewEmotionFromJson(json);

  Map<String, dynamic> toJson() => _$CreateReviewEmotionToJson(this);
}

@JsonSerializable()
class NewReviewEmotion {
  String emotion;
  int position;
  String notes;

  NewReviewEmotion({
    required this.emotion,
    required this.notes,
    required this.position,
  });

  factory NewReviewEmotion.fromJson(Map<String, dynamic> json) =>
      _$NewReviewEmotionFromJson(json);

  Map<String, dynamic> toJson() => _$NewReviewEmotionToJson(this);
}

@JsonSerializable()
class ReviewEmotionResp {
  @JsonKey(name: 'review_emotion')
  ReviewEmotion reviewEmotion;

  ReviewEmotionResp({required this.reviewEmotion});

  factory ReviewEmotionResp.fromJson(Map<String, dynamic> json) =>
      _$ReviewEmotionRespFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewEmotionRespToJson(this);
}
