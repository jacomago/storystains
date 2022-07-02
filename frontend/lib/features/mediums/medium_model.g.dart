// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medium_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Medium _$MediumFromJson(Map<String, dynamic> json) => Medium(
      name: json['name'] as String,
    );

Map<String, dynamic> _$MediumToJson(Medium instance) => <String, dynamic>{
      'name': instance.name,
    };

MediumsResp _$MediumsRespFromJson(Map<String, dynamic> json) => MediumsResp(
      mediums: (json['mediums'] as List<dynamic>)
          .map((e) => Medium.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MediumsRespToJson(MediumsResp instance) =>
    <String, dynamic>{
      'mediums': instance.mediums,
    };
