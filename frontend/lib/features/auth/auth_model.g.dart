// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      token: json['token'] as String,
      username: json['username'] as String,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'token': instance.token,
      'username': instance.username,
    };

AddUser _$AddUserFromJson(Map<String, dynamic> json) => AddUser(
      user: NewUser.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AddUserToJson(AddUser instance) => <String, dynamic>{
      'user': instance.user,
    };

NewUser _$NewUserFromJson(Map<String, dynamic> json) => NewUser(
      password: json['password'] as String,
      username: json['username'] as String,
    );

Map<String, dynamic> _$NewUserToJson(NewUser instance) => <String, dynamic>{
      'password': instance.password,
      'username': instance.username,
    };

UserResp _$UserRespFromJson(Map<String, dynamic> json) => UserResp(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserRespToJson(UserResp instance) => <String, dynamic>{
      'user': instance.user,
    };
