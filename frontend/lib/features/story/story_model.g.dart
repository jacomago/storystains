// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Story _$StoryFromJson(Map<String, dynamic> json) => Story(
      title: json['title'] as String,
      medium: Story._mediumFromName(json['medium'] as String),
      creator: json['creator'] as String,
    );

Map<String, dynamic> _$StoryToJson(Story instance) => <String, dynamic>{
      'title': instance.title,
      'medium': Story._mediumToName(instance.medium),
      'creator': instance.creator,
    };

WrappedStory _$WrappedStoryFromJson(Map<String, dynamic> json) => WrappedStory(
      story: Story.fromJson(json['story'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$WrappedStoryToJson(WrappedStory instance) =>
    <String, dynamic>{
      'story': instance.story,
    };

StoriesResp _$StoriesRespFromJson(Map<String, dynamic> json) => StoriesResp(
      stories: (json['stories'] as List<dynamic>)
          .map((e) => Story.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$StoriesRespToJson(StoriesResp instance) =>
    <String, dynamic>{
      'stories': instance.stories,
    };
