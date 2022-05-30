// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      username: json['username'] as String?,
      password: json['password'] as String?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'username': instance.username,
      'password': instance.password,
    };

FormData _$FormDataFromJson(Map<String, dynamic> json) => FormData(
      user: json['user'],
    );

Map<String, dynamic> _$FormDataToJson(FormData instance) => <String, dynamic>{
      'user': instance.user,
    };
