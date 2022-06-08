import '../../utils/prefs.dart';

class AuthStorage {
  static logout() async {
    await Prefs.remove('user');
    await Prefs.remove('token');
  }

  static getToken() async {
    await Prefs.getString('token');
  }

  static tokenExists() async {
    await Prefs.containsKey('token');
  }
}
