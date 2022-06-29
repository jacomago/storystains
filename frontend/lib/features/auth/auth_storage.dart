import 'dart:convert';

import 'package:storystains/common/utils/prefs.dart';
import 'package:storystains/features/auth/auth.dart';

class AuthStorage {
  static logout() async {
    await Prefs.remove('user');
    await Prefs.remove('token');
  }

  static Future<String?> getToken() async {
    return await Prefs.getString('token');
  }

  static Future<bool> tokenExists() async {
    return await Prefs.containsKey('token');
  }

  static Future<User?> getUser() async {
    final userString = await Prefs.getString('user');

    return userString == null ? null : User.fromJson(jsonDecode(userString));
  }

  static login(User user) async {
    await Prefs.setString('user', jsonEncode(user.toJson()));
    await Prefs.setString('token', user.token);
  }
}
