// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emotion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Emotion _$EmotionFromJson(Map<String, dynamic> json) => Emotion(
      name: json['name'] as String,
      iconUrl: json['icon_url'] as String,
      description: json['description'] as String,
    );

Map<String, dynamic> _$EmotionToJson(Emotion instance) => <String, dynamic>{
      'name': instance.name,
      'icon_url': instance.iconUrl,
      'description': instance.description,
    };
