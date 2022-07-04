import '../../common/data/network/rest_client.dart';
import '../../common/utils/service_locator.dart';

import 'auth_model.dart';

/// Wrapper around [RestClient] methods for [User]
class AuthService {
  /// Wrapper around [RestClient.addUser]
  Future<UserResp> register(String username, String password) async =>
      await ServiceLocator.sl.get<RestClient>().addUser(
            AddUser(user: NewUser(username: username, password: password)),
          );

  /// Wrapper around [RestClient.loginUser]
  Future<UserResp> login(String username, String password) async =>
      await ServiceLocator.sl.get<RestClient>().loginUser(
            AddUser(user: NewUser(username: username, password: password)),
          );

  /// Wrapper around [RestClient.deleteUser]
  Future<void> delete() async {
    await ServiceLocator.sl.get<RestClient>().deleteUser();
  }
}
