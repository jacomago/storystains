import 'package:json_annotation/json_annotation.dart';

import '../entity/review_emotion.dart';

part 'review_emotion_resp.g.dart';

@JsonSerializable()
class ReviewEmotionResp {
  @JsonKey(name: 'review_emotion')
  ReviewEmotion reviewEmotion;

  ReviewEmotionResp({required this.reviewEmotion});

  factory ReviewEmotionResp.fromJson(Map<String, dynamic> json) =>
      _$ReviewEmotionRespFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewEmotionRespToJson(this);
}
