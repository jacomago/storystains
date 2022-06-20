import 'package:storystains/model/entity/user.dart';

User testUser({String? token, String? username}) =>
    User(token: token ?? "token", username: username ?? "username");

UserProfile testUserProfile({String? username}) =>
    UserProfile(username: username ?? "username");
