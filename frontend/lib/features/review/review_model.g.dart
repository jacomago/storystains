// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Review _$ReviewFromJson(Map<String, dynamic> json) => Review(
      body: json['body'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      slug: json['slug'] as String,
      title: json['title'] as String,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      emotions: (json['emotions'] as List<dynamic>)
          .map((e) => ReviewEmotion.fromJson(e as Map<String, dynamic>))
          .toList(),
      user: UserProfile.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ReviewToJson(Review instance) => <String, dynamic>{
      'body': instance.body,
      'created_at': instance.createdAt.toIso8601String(),
      'slug': instance.slug,
      'title': instance.title,
      'updated_at': instance.updatedAt.toIso8601String(),
      'emotions': instance.emotions,
      'user': instance.user,
    };

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

ReviewResp _$ReviewRespFromJson(Map<String, dynamic> json) => ReviewResp(
      review: Review.fromJson(json['review'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ReviewRespToJson(ReviewResp instance) =>
    <String, dynamic>{
      'review': instance.review,
    };
