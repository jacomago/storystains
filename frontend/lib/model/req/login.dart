import 'package:json_annotation/json_annotation.dart';

part 'login.g.dart';

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
