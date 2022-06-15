// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_emotion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewEmotion _$ReviewEmotionFromJson(Map<String, dynamic> json) =>
    ReviewEmotion(
      notes: json['notes'] as String,
      name: json['name'] as String,
      position: json['position'] as int,
    );

Map<String, dynamic> _$ReviewEmotionToJson(ReviewEmotion instance) =>
    <String, dynamic>{
      'notes': instance.notes,
      'name': instance.name,
      'position': instance.position,
    };
