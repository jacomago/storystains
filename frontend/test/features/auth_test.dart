import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storystains/features/auth/auth.dart';
import 'package:storystains/model/entity/user.dart';
import 'package:storystains/model/resp/user_resp.dart';
import 'package:mockito/annotations.dart';

import 'auth_test.mocks.dart';

@GenerateMocks([AuthService])
void main() {
  setUp(() => {WidgetsFlutterBinding.ensureInitialized()});
  group("login", () {
    test('After logging in isAuthenticated', () async {
      SharedPreferences.setMockInitialValues({});
      const username = "username";
      const password = "password";
      final user = User(token: "token", username: username);
      final userResp = UserResp(user: user);

      final mockService = MockAuthService();
      final authState = AuthState(mockService);

      expect(authState.isAuthenticated, false);

      when(mockService.login(username, password))
          .thenAnswer((realInvocation) async => userResp);

      await authState.login(username, password);

      verify(mockService.login(username, password));
      expect(authState.isAuthenticated, true);
    });
    test('error message on bad info', () async {
      final mockService = MockAuthService();
      final authState = AuthState(mockService);

      expect(authState.isAuthenticated, false);

      when(mockService.login("", "")).thenAnswer((realInvocation) async =>
          Response(requestOptions: RequestOptions(path: ""), statusCode: 401));

      await authState.login("", "");

      verify(mockService.login("", ""));
      expect(authState.isAuthenticated, false);
      expect(authState.error, "");
    });
  });
  group("signup", () {
    test('After signup in isAuthenticated', () async {
      SharedPreferences.setMockInitialValues({});
      const username = "username";
      const password = "password";
      final user = User(token: "token", username: username);
      final userResp = UserResp(user: user);

      final mockService = MockAuthService();
      final authState = AuthState(mockService);

      expect(authState.isAuthenticated, false);

      when(mockService.register(username, password))
          .thenAnswer((realInvocation) async => userResp);

      await authState.register(username, password);

      verify(mockService.register(username, password));
      expect(authState.isAuthenticated, true);
    });
  
    test('error message on bad info', () async {
      final mockService = MockAuthService();
      final authState = AuthState(mockService);

      expect(authState.isAuthenticated, false);

      when(mockService.register("", "")).thenAnswer((realInvocation) async =>
          Response(requestOptions: RequestOptions(path: ""), statusCode: 401));

      await authState.register("", "");

      verify(mockService.register("", ""));
      expect(authState.isAuthenticated, false);
      expect(authState.error, "");
    });
  });
  group("logout", () {
    test('After logout not isAuthenticated', () async {
      SharedPreferences.setMockInitialValues({});
      const username = "username";
      const password = "password";
      final user = User(token: "token", username: username);
      final userResp = UserResp(user: user);

      final mockService = MockAuthService();
      final authState = AuthState(mockService);

      expect(authState.isAuthenticated, false);

      when(mockService.register(username, password))
          .thenAnswer((realInvocation) async => userResp);

      await authState.register(username, password);

      verify(mockService.register(username, password));
      expect(authState.isAuthenticated, true);

      await authState.logout();
      expect(authState.isAuthenticated, false);
    });
  });
}
