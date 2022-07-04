import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../common/utils/service_locator.dart';
import 'auth.dart';

/// Wrapper around some flutter secure storage methods for storing auth tokens
class AuthStorage {
  /// key for storage
  static const key = 'user';

  /// Options on android
  static const aOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );
  late final FlutterSecureStorage _secureStorage;

  /// Wrapper around some flutter secure storage methods for storing auth tokens
  AuthStorage([FlutterSecureStorage? secureStorage]) {
    _secureStorage =
        secureStorage ?? ServiceLocator.sl.get<FlutterSecureStorage>();
  }

  /// Removes the key from storage
  Future<void> logout() async {
    await _secureStorage.delete(
      key: key,
      aOptions: aOptions,
    );
  }

  /// get token from storage
  Future<String?> getToken() async {
    final userString = await _secureStorage.read(
      key: key,
      aOptions: aOptions,
    );

    return userString == null
        ? null
        : User.fromJson(jsonDecode(userString) as Map<String, dynamic>).token;
  }

  /// check if token exists in storage
  Future<bool> tokenExists() async => await _secureStorage.containsKey(
        key: key,
        aOptions: aOptions,
      );

  /// Get user from storage
  Future<User?> getUser() async {
    final userString = await _secureStorage.read(
      key: key,
      aOptions: aOptions,
    );

    return userString == null
        ? null
        : User.fromJson(jsonDecode(userString) as Map<String, dynamic>);
  }

  /// store token and user in storage
  Future<void> login(User user) async {
    await _secureStorage.write(
      key: key,
      value: jsonEncode(user),
      aOptions: aOptions,
    );
  }
}
