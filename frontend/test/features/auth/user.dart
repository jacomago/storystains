import 'package:mockito/mockito.dart';
import 'package:storystains/features/auth/auth.dart';
import 'package:storystains/features/user/user.dart';

import 'auth_test.mocks.dart';

User testUser({String? token, String? username}) =>
    User(token: token ?? 'token', username: username ?? 'username');

UserProfile testUserProfile({String? username}) =>
    UserProfile(username: username ?? 'username');

Future<AuthState> loggedInState({String? username}) async {
  final user = testUser(username: username);
  const password = 'password';
  final userResp = UserResp(user: user);

  final mockService = MockAuthService();
  final authState = AuthState(mockService);

  when(mockService.login(user.username, password))
      .thenAnswer((realInvocation) async => userResp);

  await authState.loginRegister(user.username, password);

  return authState;
}
