import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import '../mediums/medium.dart';

part 'story_model.g.dart';

@JsonSerializable()
@immutable
class Story {
  final String title;
  @JsonKey(
    fromJson: _mediumFromName,
    toJson: _mediumToName,
  )
  final Medium medium;
  final String creator;

  const Story({
    required this.title,
    required this.medium,
    required this.creator,
  });

  factory Story.fromJson(Map<String, dynamic> json) => _$StoryFromJson(json);

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

@JsonSerializable()
class WrappedStory {
  Story story;

  WrappedStory({required this.story});

  factory WrappedStory.fromJson(Map<String, dynamic> json) =>
      _$WrappedStoryFromJson(json);

  Map<String, dynamic> toJson() => _$WrappedStoryToJson(this);
}
