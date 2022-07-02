import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:storystains/features/mediums/medium.dart';

part 'story_model.g.dart';

@JsonSerializable()
class Story {
  String title;
  Medium medium;
  String creator;

  Story({
    required this.title,
    required this.medium,
    required this.creator,
  });

  factory Story.fromJson(Map<String, dynamic> json) => _$StoryFromJson(json);

  Map<String, dynamic> toJson() => _$StoryToJson(this);

  @override
  String toString() {
    return json.encode(toJson());
  }
}

@JsonSerializable()
class CreateStory {
  NewStory story;

  CreateStory({required this.story});

  factory CreateStory.fromJson(Map<String, dynamic> json) =>
      _$CreateStoryFromJson(json);

  Map<String, dynamic> toJson() => _$CreateStoryToJson(this);
}

@JsonSerializable()
class NewStory {
  String title;
  String medium;
  String creator;

  NewStory({
    required this.title,
    required this.medium,
    required this.creator,
  });

  factory NewStory.fromJson(Map<String, dynamic> json) =>
      _$NewStoryFromJson(json);

  Map<String, dynamic> toJson() => _$NewStoryToJson(this);
}

@JsonSerializable()
class StoryResp {
  Story story;

  StoryResp({required this.story});

  factory StoryResp.fromJson(Map<String, dynamic> json) =>
      _$StoryRespFromJson(json);

  Map<String, dynamic> toJson() => _$StoryRespToJson(this);
}
