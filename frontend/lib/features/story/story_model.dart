import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import '../mediums/medium.dart';

part 'story_model.g.dart';

@JsonSerializable()
@immutable

/// Story representaion
class Story {
  @JsonKey(
    fromJson: _mediumFromName,
    toJson: _mediumToName,
  )

  /// title of a story
  final String title;

  /// Medium of a story such as [Medium] ('Book')
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
