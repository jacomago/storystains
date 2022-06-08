import '../../utils/prefs.dart';

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
}
