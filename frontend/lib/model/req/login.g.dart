// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Login _$LoginFromJson(Map<String, dynamic> json) => Login(
      user: LoginUser.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LoginToJson(Login instance) => <String, dynamic>{
      'user': instance.user,
    };

LoginUser _$LoginUserFromJson(Map<String, dynamic> json) => LoginUser(
      username: json['username'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$LoginUserToJson(LoginUser instance) => <String, dynamic>{
      'username': instance.username,
      'password': instance.password,
    };
