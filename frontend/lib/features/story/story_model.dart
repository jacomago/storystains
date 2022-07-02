import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'story_model.g.dart';

@JsonSerializable()
class Story {
  String title;
  String medium;
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
