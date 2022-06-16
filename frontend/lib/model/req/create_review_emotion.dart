import 'package:json_annotation/json_annotation.dart';

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
  String name;
  int position;
  String notes;

  NewReviewEmotion({
    required this.name,
    required this.notes,
    required this.position,
  });

  factory NewReviewEmotion.fromJson(Map<String, dynamic> json) =>
      _$NewReviewEmotionFromJson(json);

  Map<String, dynamic> toJson() => _$NewReviewEmotionToJson(this);
}
