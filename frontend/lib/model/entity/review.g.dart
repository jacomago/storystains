// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Review _$ReviewFromJson(Map<String, dynamic> json) => Review(
      body: json['body'] as String,
      createdAt: json['created_at'] as String,
      slug: json['slug'] as String,
      title: json['title'] as String,
      updatedAt: json['updated_at'] as String,
    );

Map<String, dynamic> _$ReviewToJson(Review instance) => <String, dynamic>{
      'body': instance.body,
      'created_at': instance.createdAt,
      'slug': instance.slug,
      'title': instance.title,
      'updated_at': instance.updatedAt,
    };
