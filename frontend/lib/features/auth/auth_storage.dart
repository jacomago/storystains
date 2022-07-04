import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../common/utils/service_locator.dart';
import 'auth.dart';

class AuthStorage {
  static const key = 'user';
  static const aOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );
  late final FlutterSecureStorage _secureStorage;

  AuthStorage() {
    _secureStorage = ServiceLocator.sl.get<FlutterSecureStorage>();
  }

  Future<void> logout() async {
    await _secureStorage.delete(
      key: key,
      aOptions: aOptions,
    );
  }

  Future<String?> getToken() async {
    final userString = await _secureStorage.read(
      key: key,
      aOptions: aOptions,
    );

    return userString == null
        ? null
        : User.fromJson(jsonDecode(userString) as Map<String, dynamic>).token;
  }

  Future<bool> tokenExists() async => await _secureStorage.containsKey(
        key: key,
        aOptions: aOptions,
      );

  Future<User?> getUser() async {
    final userString = await _secureStorage.read(
      key: key,
      aOptions: aOptions,
    );

    return userString == null
        ? null
        : User.fromJson(jsonDecode(userString) as Map<String, dynamic>);
  }

  Future<void> login(User user) async {
    await _secureStorage.write(
      key: key,
      value: jsonEncode(user),
      aOptions: aOptions,
    );
  }
}
