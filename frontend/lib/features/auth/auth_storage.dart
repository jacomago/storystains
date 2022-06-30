import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:storystains/common/utils/service_locator.dart';
import 'package:storystains/features/auth/auth.dart';

class AuthStorage {
  static const key = 'user';
  static logout() async {
    final storage = sl.get<FlutterSecureStorage>();
    await storage.delete(key: key);
  }

  static Future<String?> getToken() async {
    final storage = sl.get<FlutterSecureStorage>();

    final userString = await storage.read(key: key);

    return userString == null
        ? null
        : User.fromJson(jsonDecode(userString)).token;
  }

  static Future<bool> tokenExists() async {
    final storage = sl.get<FlutterSecureStorage>();

    return await storage.containsKey(key: key);
  }

  static Future<User?> getUser() async {
    final storage = sl.get<FlutterSecureStorage>();
    final userString = await storage.read(key: key);

    return userString == null ? null : User.fromJson(jsonDecode(userString));
  }

  static login(User user) async {
    final storage = sl.get<FlutterSecureStorage>();
    await storage.write(key: key, value: jsonEncode(user));
  }
}
