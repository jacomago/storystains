import 'package:json_annotation/json_annotation.dart';

part 'auth_model.g.dart';

/// Representation of a user
@JsonSerializable()
class User {
  /// Username of user
  String username;

  /// Representation of a user constructor
  User({
    required this.username,
  });

  /// user from json
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  /// user to json
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

/// New user for api
@JsonSerializable()
class AddUser {
  /// user and pass
  NewUser user;

  /// user and pass
  AddUser({required this.user});

  /// user and pass from json
  factory AddUser.fromJson(Map<String, dynamic> json) =>
      _$AddUserFromJson(json);

  /// user and pass to json
  Map<String, dynamic> toJson() => _$AddUserToJson(this);
}

/// user and pass
@JsonSerializable()
class NewUser {
  /// pass
  String password;

  /// username
  String username;

  /// user and pass
  NewUser({
    required this.password,
    required this.username,
  });

  /// user and pass from json
  factory NewUser.fromJson(Map<String, dynamic> json) =>
      _$NewUserFromJson(json);

  /// user and pass to json
  Map<String, dynamic> toJson() => _$NewUserToJson(this);
}

/// response from server after auth
@JsonSerializable()
class UserResp {
  /// user rep
  User user;

  /// response from server after auth
  UserResp({required this.user});

  /// response from server after auth from json
  factory UserResp.fromJson(Map<String, dynamic> json) =>
      _$UserRespFromJson(json);

  /// response from server after auth to json
  Map<String, dynamic> toJson() => _$UserRespToJson(this);
}
