// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emotion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Emotion _$EmotionFromJson(Map<String, dynamic> json) => Emotion(
      name: json['name'] as String,
      iconUrl: json['iconUrl'] as String,
      description: json['description'] as String,
    );

Map<String, dynamic> _$EmotionToJson(Emotion instance) => <String, dynamic>{
      'name': instance.name,
      'iconUrl': instance.iconUrl,
      'description': instance.description,
    };
