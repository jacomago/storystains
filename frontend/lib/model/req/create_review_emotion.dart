import 'package:json_annotation/json_annotation.dart';
import 'package:storystains/model/entity/emotion.dart';

part 'create_review_emotion.g.dart';

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
  Emotion emotion;
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
