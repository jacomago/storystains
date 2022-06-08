import '../../utils/prefs.dart';

export 'auth_state.dart';
export 'auth_service.dart';

class Auth {
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
