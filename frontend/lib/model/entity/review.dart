import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'review.g.dart';

@JsonSerializable()
class Review {
  String body;
  String createdAt;
  String slug;
  String title;
  String updatedAt;

  Review({
    required this.body,
    required this.createdAt,
    required this.slug,
    required this.title,
    required this.updatedAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewToJson(this);

  @override
  String toString() {
    return json.encode(toJson());
  }
}
