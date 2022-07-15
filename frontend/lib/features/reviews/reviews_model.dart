import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import '../review/review_model.dart';
import '../story/story.dart';

part 'reviews_model.g.dart';

/// Model for rest api of reviews in a list
@JsonSerializable()
class ReviewsResp {
  /// List of reviews
  List<Review> reviews;

  /// Model for rest api of reviews in a list
  ReviewsResp({required this.reviews});

  /// Model for rest api of reviews in a list from json
  factory ReviewsResp.fromJson(Map<String, dynamic> json) =>
      _$ReviewsRespFromJson(json);

  /// Model for rest api of reviews in a list to json
  Map<String, dynamic> toJson() => _$ReviewsRespToJson(this);
}

/// Class for representing query options on searching for reviews
@immutable
class ReviewQuery {
  /// username of user who created review
  final String? username;

  /// options for searching by story
  final StoryQuery storyQuery;

  /// Constructor for [ReviewQuery]
  const ReviewQuery({this.username, this.storyQuery = const StoryQuery()});

  @override
  String toString() =>
      'ReviewQuery: username: $username, storyQuery: $storyQuery';

  @override
  bool operator ==(Object other) =>
      other is ReviewQuery &&
      username == other.username &&
      storyQuery == other.storyQuery;

  @override
  int get hashCode => username.hashCode + storyQuery.hashCode;
}
