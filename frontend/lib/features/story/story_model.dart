import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:storystains/features/mediums/medium.dart';

part 'story_model.g.dart';

@JsonSerializable()
class Story {
  String title;
  @JsonKey(
    fromJson: _mediumFromName,
    toJson: _mediumToName,
  )
  Medium medium;
  String creator;

  Story({
    required this.title,
    required this.medium,
    required this.creator,
  });

  factory Story.fromJson(Map<String, dynamic> json) => _$StoryFromJson(json);

  Map<String, dynamic> toJson() => _$StoryToJson(this);

  static Medium _mediumFromName(String name) => Medium(name: name);
  static String _mediumToName(Medium medium) => medium.name;

  @override
  String toString() {
    return json.encode(toJson());
  }

  @override
  bool operator ==(Object other) {
    return other is Story &&
        title == other.title &&
        creator == other.creator &&
        medium == other.medium;
  }

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
