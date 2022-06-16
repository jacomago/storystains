// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_emotion_resp.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewEmotionResp _$ReviewEmotionRespFromJson(Map<String, dynamic> json) =>
    ReviewEmotionResp(
      reviewEmotion: ReviewEmotion.fromJson(
          json['review_emotion'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ReviewEmotionRespToJson(ReviewEmotionResp instance) =>
    <String, dynamic>{
      'review_emotion': instance.reviewEmotion,
    };
