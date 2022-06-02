import 'package:json_annotation/json_annotation.dart';

import '../entity/review.dart';

part 'review_resp.g.dart';

@JsonSerializable()
class ReviewResp {
  Review review;

  ReviewResp({required this.review});

  factory ReviewResp.fromJson(Map<String, dynamic> json) =>
      _$ReviewRespFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewRespToJson(this);
}
