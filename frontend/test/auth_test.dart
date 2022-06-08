import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storystains/features/auth/auth.dart';
import 'package:storystains/model/entity/user.dart';
import 'package:storystains/model/req/add_user.dart';
import 'package:storystains/model/resp/user_resp.dart';
import 'package:mockito/annotations.dart';
import 'package:storystains/utils/prefs.dart';

import 'auth_test.mocks.dart';

final _headers = {"Content-Type": "application/json"};

@GenerateMocks([AuthService])
void main() {
  setUp(() => {WidgetsFlutterBinding.ensureInitialized()});
  group("auth", () {
    test('returns an User if the http call completes successfully', () async {
      SharedPreferences.setMockInitialValues({});
      // Use Mockito to return a successful response when it calls the
      // provided Client
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
    test('auth manager successfully stores user to be logged in', () async {
      

    });
  });
}

// TODO Test Signup
// TODO Test handle signup error
// TODO Test Login
// TODO Test handle login error
// TODO Test Logout
// TODO Test handle logout error
