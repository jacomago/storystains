// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Story _$StoryFromJson(Map<String, dynamic> json) => Story(
      title: json['title'] as String,
      medium: Medium.fromJson(json['medium'] as Map<String, dynamic>),
      creator: json['creator'] as String,
    );

Map<String, dynamic> _$StoryToJson(Story instance) => <String, dynamic>{
      'title': instance.title,
      'medium': instance.medium,
      'creator': instance.creator,
    };

CreateStory _$CreateStoryFromJson(Map<String, dynamic> json) => CreateStory(
      story: NewStory.fromJson(json['story'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CreateStoryToJson(CreateStory instance) =>
    <String, dynamic>{
      'story': instance.story,
    };

NewStory _$NewStoryFromJson(Map<String, dynamic> json) => NewStory(
      title: json['title'] as String,
      medium: json['medium'] as String,
      creator: json['creator'] as String,
    );

Map<String, dynamic> _$NewStoryToJson(NewStory instance) => <String, dynamic>{
      'title': instance.title,
      'medium': instance.medium,
      'creator': instance.creator,
    };

StoryResp _$StoryRespFromJson(Map<String, dynamic> json) => StoryResp(
      story: Story.fromJson(json['story'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StoryRespToJson(StoryResp instance) => <String, dynamic>{
      'story': instance.story,
    };
