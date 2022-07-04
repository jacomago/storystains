import 'package:storystains/common/data/network/rest_client.dart';
import 'package:storystains/common/utils/service_locator.dart';

import 'auth_model.dart';

class AuthService {
  Future<UserResp> register(String username, String password) async {
    return await sl.get<RestClient>().addUser(
          AddUser(user: NewUser(username: username, password: password)),
        );
  }

  Future<UserResp> login(String username, String password) async {
    final resp = await sl.get<RestClient>().loginUser(
          Login(user: LoginUser(username: username, password: password)),
        );

    return resp;
  }

  Future<void> delete() async {
    await sl.get<RestClient>().deleteUser();
  }
}
