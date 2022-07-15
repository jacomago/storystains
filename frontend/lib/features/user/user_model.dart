import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

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
