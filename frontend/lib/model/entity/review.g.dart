// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Review _$ReviewFromJson(Map<String, dynamic> json) => Review(
      body: json['body'] as String,
      createdAt: json['createdAt'] as String,
      slug: json['slug'] as String,
      title: json['title'] as String,
      updatedAt: json['updatedAt'] as String,
    );

Map<String, dynamic> _$ReviewToJson(Review instance) => <String, dynamic>{
      'body': instance.body,
      'createdAt': instance.createdAt,
      'slug': instance.slug,
      'title': instance.title,
      'updatedAt': instance.updatedAt,
    };
