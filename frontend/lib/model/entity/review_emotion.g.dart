// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_emotion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewEmotion _$ReviewEmotionFromJson(Map<String, dynamic> json) =>
    ReviewEmotion(
      notes: json['notes'] as String,
      emotion: Emotion.fromJson(json['emotion'] as Map<String, dynamic>),
      position: json['position'] as int,
    );

Map<String, dynamic> _$ReviewEmotionToJson(ReviewEmotion instance) =>
    <String, dynamic>{
      'notes': instance.notes,
      'emotion': instance.emotion,
      'position': instance.position,
    };
