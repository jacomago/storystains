// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reviews_resp.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewsResp _$ReviewsRespFromJson(Map<String, dynamic> json) => ReviewsResp(
      reviews: (json['reviews'] as List<dynamic>)
          .map((e) => Review.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ReviewsRespToJson(ReviewsResp instance) =>
    <String, dynamic>{
      'reviews': instance.reviews,
    };
