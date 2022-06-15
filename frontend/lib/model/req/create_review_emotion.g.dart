// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_review_emotion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateReviewEmotion _$CreateReviewEmotionFromJson(Map<String, dynamic> json) =>
    CreateReviewEmotion(
      review_emotion: NewReviewEmotion.fromJson(
          json['review_emotion'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CreateReviewEmotionToJson(
        CreateReviewEmotion instance) =>
    <String, dynamic>{
      'review_emotion': instance.review_emotion,
    };

NewReviewEmotion _$NewReviewEmotionFromJson(Map<String, dynamic> json) =>
    NewReviewEmotion(
      name: json['name'] as String,
      notes: json['notes'] as String,
      position: json['position'] as int,
    );

Map<String, dynamic> _$NewReviewEmotionToJson(NewReviewEmotion instance) =>
    <String, dynamic>{
      'name': instance.name,
      'position': instance.position,
      'notes': instance.notes,
    };
