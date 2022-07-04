import '../../common/data/network/rest_client.dart';
import '../../common/utils/service_locator.dart';

import 'auth_model.dart';

class AuthService {
  Future<UserResp> register(String username, String password) async =>
      await ServiceLocator.sl.get<RestClient>().addUser(
            AddUser(user: NewUser(username: username, password: password)),
          );

  Future<UserResp> login(String username, String password) async =>
      await ServiceLocator.sl.get<RestClient>().loginUser(
            Login(user: LoginUser(username: username, password: password)),
          );

  Future<void> delete() async {
    await ServiceLocator.sl.get<RestClient>().deleteUser();
  }
}
