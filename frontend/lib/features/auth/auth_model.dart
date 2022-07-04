import 'package:json_annotation/json_annotation.dart';

part 'auth_model.g.dart';

/// Representation of a user with auth token
@JsonSerializable()
class User {
  /// Token for auth
  String token;

  /// Username of user
  String username;

  /// Representation of a user with auth token
  User({
    required this.token,
    required this.username,
  });

  /// user from json
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  /// user to json
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

/// representation of user to others
@JsonSerializable()
class UserProfile {
  /// username
  String username;

  /// representation of user to others
  UserProfile({
    required this.username,
  });

  /// profile from json
  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  /// Profile to json
  Map<String, dynamic> toJson() => _$UserProfileToJson(this);
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

/// request type for user
@JsonSerializable()
class Login {
  /// request type for user
  LoginUser user;

  /// request type for user
  Login({required this.user});

  /// request type for user from json
  factory Login.fromJson(Map<String, dynamic> json) => _$LoginFromJson(json);

  /// request type for user to json
  Map<String, dynamic> toJson() => _$LoginToJson(this);
}

/// request type for user
@JsonSerializable()
class LoginUser {
  /// user
  String username;

  /// pass
  String password;

  /// request type for user
  LoginUser({
    required this.username,
    required this.password,
  });

  /// request type for user from json
  factory LoginUser.fromJson(Map<String, dynamic> json) =>
      _$LoginUserFromJson(json);

  /// request type for user to json
  Map<String, dynamic> toJson() => _$LoginUserToJson(this);
}
