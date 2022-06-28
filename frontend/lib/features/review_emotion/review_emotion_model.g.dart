// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_emotion_model.dart';

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

ReviewEmotionResp _$ReviewEmotionRespFromJson(Map<String, dynamic> json) =>
    ReviewEmotionResp(
      reviewEmotion: ReviewEmotion.fromJson(
          json['review_emotion'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ReviewEmotionRespToJson(ReviewEmotionResp instance) =>
    <String, dynamic>{
      'review_emotion': instance.reviewEmotion,
    };
