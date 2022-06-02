// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateReview _$CreateReviewFromJson(Map<String, dynamic> json) => CreateReview(
      review: NewReview.fromJson(json['review'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CreateReviewToJson(CreateReview instance) =>
    <String, dynamic>{
      'review': instance.review,
    };

NewReview _$NewReviewFromJson(Map<String, dynamic> json) => NewReview(
      body: json['body'] as String,
      title: json['title'] as String,
    );

Map<String, dynamic> _$NewReviewToJson(NewReview instance) => <String, dynamic>{
      'body': instance.body,
      'title': instance.title,
    };
