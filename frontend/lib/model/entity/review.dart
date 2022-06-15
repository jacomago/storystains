import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:storystains/model/entity/review_emotion.dart';
import 'package:storystains/model/entity/user.dart';

part 'review.g.dart';

@JsonSerializable()
class Review {
  String body;
  @JsonKey(name: 'created_at')
  DateTime createdAt;
  String slug;
  String title;
  @JsonKey(name: 'updated_at')
  DateTime updatedAt;
  List<ReviewEmotion> emotions;
  UserProfile user;

  Review(
      {required this.body,
      required this.createdAt,
      required this.slug,
      required this.title,
      required this.updatedAt,
      required this.emotions,
      required this.user});

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewToJson(this);

  @override
  String toString() {
    return json.encode(toJson());
  }
}
