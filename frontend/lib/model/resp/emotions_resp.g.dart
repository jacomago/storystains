// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emotions_resp.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmotionsResp _$EmotionsRespFromJson(Map<String, dynamic> json) => EmotionsResp(
      emotions: (json['emotions'] as List<dynamic>)
          .map((e) => Emotion.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$EmotionsRespToJson(EmotionsResp instance) =>
    <String, dynamic>{
      'emotions': instance.emotions,
    };
