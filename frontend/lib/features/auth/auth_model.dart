import 'package:json_annotation/json_annotation.dart';

part 'auth_model.g.dart';

@JsonSerializable()
class User {
  String token;
  String username;

  User({
    required this.token,
    required this.username,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class UserProfile {
  String username;

  UserProfile({
    required this.username,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileToJson(this);
}

@JsonSerializable()
class AddUser {
  NewUser user;

  AddUser({required this.user});

  factory AddUser.fromJson(Map<String, dynamic> json) =>
      _$AddUserFromJson(json);

  Map<String, dynamic> toJson() => _$AddUserToJson(this);
}

@JsonSerializable()
class NewUser {
  String password;
  String username;

  NewUser({
    required this.password,
    required this.username,
  });

  factory NewUser.fromJson(Map<String, dynamic> json) =>
      _$NewUserFromJson(json);

  Map<String, dynamic> toJson() => _$NewUserToJson(this);
}

@JsonSerializable()
class UserResp {
  User user;

  UserResp({required this.user});

  factory UserResp.fromJson(Map<String, dynamic> json) =>
      _$UserRespFromJson(json);

  Map<String, dynamic> toJson() => _$UserRespToJson(this);
}

@JsonSerializable()
class Login {
  LoginUser user;

  Login({required this.user});

  factory Login.fromJson(Map<String, dynamic> json) => _$LoginFromJson(json);

  Map<String, dynamic> toJson() => _$LoginToJson(this);
}

@JsonSerializable()
class LoginUser {
  String username;
  String password;

  LoginUser({
    required this.username,
    required this.password,
  });

  factory LoginUser.fromJson(Map<String, dynamic> json) =>
      _$LoginUserFromJson(json);

  Map<String, dynamic> toJson() => _$LoginUserToJson(this);
}
