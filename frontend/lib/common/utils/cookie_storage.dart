import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

///Save cookies in  files

class CookieStorage implements Storage {
  /// Constructor for persistant cookie storage using flutter secure storage
  CookieStorage(this._secureStorage);

  /// Options on android
  static const aOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );

  /// [_secureStorage]: where the cookie files saved in,
  final FlutterSecureStorage _secureStorage;

  @override
  Future<void> delete(String key) async {
    if (await _secureStorage.containsKey(key: key, aOptions: aOptions)) {
      await _secureStorage.delete(key: key);
    }
  }

  @override
  Future<void> deleteAll(List<String> keys) async {
    await _secureStorage.deleteAll(aOptions: aOptions);
  }

  @override
  // ignore: no-empty-block
  Future<void> init(bool persistSession, bool ignoreExpires) async {}

  @override
  Future<String?> read(String key) async {
    if (await _secureStorage.containsKey(key: key, aOptions: aOptions)) {
      return _secureStorage.read(key: key, aOptions: aOptions);
    }

    return null;
  }

  @override
  Future<void> write(String key, String value) async {
    await _secureStorage.write(key: key, value: value, aOptions: aOptions);
  }
}
