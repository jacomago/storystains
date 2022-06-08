import '../../data/network/api.dart';
import '../../model/req/add_user.dart';
import '../../model/req/login.dart';

class AuthService {
  Future register(String username, String password) async {
    return await Api.register(
        AddUser(user: NewUser(username: username, password: password)));
  }

  Future login(String username, String password) async {
    return await Api.login(
        Login(user: LoginUser(username: username, password: password)));
  }

}
