// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_review_emotion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateReviewEmotion _$CreateReviewEmotionFromJson(Map<String, dynamic> json) =>
    CreateReviewEmotion(
      reviewEmotion: NewReviewEmotion.fromJson(
          json['review_emotion'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CreateReviewEmotionToJson(
        CreateReviewEmotion instance) =>
    <String, dynamic>{
      'review_emotion': instance.reviewEmotion,
    };

NewReviewEmotion _$NewReviewEmotionFromJson(Map<String, dynamic> json) =>
    NewReviewEmotion(
      emotion: json['emotion'] as String,
      notes: json['notes'] as String,
      position: json['position'] as int,
    );

Map<String, dynamic> _$NewReviewEmotionToJson(NewReviewEmotion instance) =>
    <String, dynamic>{
      'emotion': instance.emotion,
      'position': instance.position,
      'notes': instance.notes,
    };
