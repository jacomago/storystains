// ignore_for_file: avoid_classes_with_only_static_members

import 'package:shared_preferences/shared_preferences.dart';

/// Wrapper methods around [SharedPreferences]
class Prefs {
  static SharedPreferences? _prefs;

  static Future<void> _init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Get string from storage
  static Future<String?> getString(String key) async {
    await _init();

    return _prefs!.getString(key);
  }

  /// Check if key in storage
  static Future<bool> containsKey(String key) async {
    await _init();

    return _prefs!.containsKey(key);
  }

  /// Set string in storage
  static Future<bool> setString(String key, String value) async {
    await _init();

    return await _prefs!.setString(key, value);
  }

  /// remove string from storage
  static Future<bool> remove(String key) async {
    await _init();

    return await _prefs!.remove(key);
  }
}
