import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import '../mediums/medium.dart';

part 'story_model.g.dart';

@JsonSerializable()
@immutable

/// Story representaion
class Story {
  /// title of a story
  final String title;

  /// Medium of a story such as [Medium] ('Book')
  @JsonKey(
    fromJson: _mediumFromName,
    toJson: _mediumToName,
  )
  final Medium medium;

  /// Creator of a story such as 'Frank Herbert'
  final String creator;

  /// Story representation
  const Story({
    required this.title,
    required this.medium,
    required this.creator,
  });

  /// Create a Story from a Json string
  factory Story.fromJson(Map<String, dynamic> json) => _$StoryFromJson(json);

  /// Create Json from a Story
  Map<String, dynamic> toJson() => _$StoryToJson(this);

  static Medium _mediumFromName(String name) => Medium(name: name);
  static String _mediumToName(Medium medium) => medium.name;

  @override
  String toString() => json.encode(toJson());

  @override
  bool operator ==(Object other) =>
      other is Story &&
      title == other.title &&
      creator == other.creator &&
      medium == other.medium;

  @override
  int get hashCode => title.hashCode + creator.hashCode + medium.hashCode;
}

/// Wrapper up story for using the api
@JsonSerializable()
class WrappedStory {
  /// Wrapped up story
  Story story;

  /// Wrapper up story for using the api
  WrappedStory({required this.story});

  /// Wrapper up story from json
  factory WrappedStory.fromJson(Map<String, dynamic> json) =>
      _$WrappedStoryFromJson(json);

  /// Wrapper up story to json for using the api
  Map<String, dynamic> toJson() => _$WrappedStoryToJson(this);
}

/// Model for rest api of stories in a list
@JsonSerializable()
class StoriesResp {
  /// List of reviews
  List<Story> stories;

  /// Model for rest api of stories in a list
  StoriesResp({required this.stories});

  /// Model for rest api of stories in a list from json
  factory StoriesResp.fromJson(Map<String, dynamic> json) =>
      _$StoriesRespFromJson(json);

  /// Model for rest api of stories in a list to json
  Map<String, dynamic> toJson() => _$StoriesRespToJson(this);
}

/// Class for representing query options on searching by story
@immutable
class StoryQuery {
  /// title of a story
  final String? title;

  /// Medium of a story such as [Medium] ('Book')´
  final Medium? medium;

  /// creator of a story
  final String? creator;

  /// Constructor of [StoryQuery]
  const StoryQuery({this.title, this.medium, this.creator});

  @override
  String toString() =>
      'StoryQuery: title: $title, creator: $creator, medium: ${medium?.name}';

  @override
  bool operator ==(Object other) =>
      other is StoryQuery &&
      title == other.title &&
      creator == other.creator &&
      medium == other.medium;

  @override
  int get hashCode => title.hashCode + creator.hashCode + medium.hashCode;
}
