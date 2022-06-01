import 'package:storystains/data/network/api.dart';

class AuthService {
  Future register(String username, String password) async {
    return await UserApi.register(username, password);
  }

  Future login(String username, String password) async {
    return await UserApi.login(username, password);
  }

  Future user(int id) async {
    return await UserApi.user(id);
  }
}
