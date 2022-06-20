import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:storystains/model/entity/emotion.dart';

part 'review_emotion.g.dart';

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
