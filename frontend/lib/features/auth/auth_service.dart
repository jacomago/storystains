import 'package:storystains/common/data/network/rest_client.dart';
import 'package:storystains/common/utils/services.dart';
import '../../model/req/add_user.dart';
import '../../model/req/login.dart';

class AuthService {
  Future register(String username, String password) async {
    return await sl.get<RestClient>().addUser(
          AddUser(user: NewUser(username: username, password: password)),
        );
  }

  Future login(String username, String password) async {
    final resp = await sl.get<RestClient>().loginUser(
          Login(user: LoginUser(username: username, password: password)),
        );

    return resp;
  }
}
