import 'package:flutter_test/flutter_test.dart';

import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storystains/modules/auth/auth.dart';

import 'auth_test.mocks.dart';

@GenerateMocks([AuthService])
void main() async {
  group('basic auth', () {
    test('starts not logged in', () async {
      final authService = AuthService();
      final authState = AuthState(authService);

      expect(authState.isAuthenticated, false);
    });

    test('logging in', () async {
      SharedPreferences.setMockInitialValues({});
      final mockAuthService = MockAuthService();
      final authState = AuthState(mockAuthService);

      when(mockAuthService.login("user", "password")).thenAnswer((_) async => {
            "user": {"username": "user", "token": "token"}
          });
      await authState.login("user", "password");

      expect(authState.isAuthenticated, true);
    });

    test('register', () async {
      SharedPreferences.setMockInitialValues({});
      final mockAuthService = MockAuthService();
      final authState = AuthState(mockAuthService);

      when(mockAuthService.register("user", "password"))
          .thenAnswer((_) async => {
                "user": {"username": "user", "token": "token"}
              });
      await authState.register("user", "password");

      expect(authState.isAuthenticated, true);
    });

    test('log out', () async {
      SharedPreferences.setMockInitialValues({});
      final mockAuthService = MockAuthService();
      final authState = AuthState(mockAuthService);

      when(mockAuthService.login("user", "password")).thenAnswer((_) async => {
            "user": {"username": "user", "token": "token"}
          });
      await authState.login("user", "password");

      expect(authState.isAuthenticated, true);

      await authState.logout();
      expect(authState.isAuthenticated, false);
    });
  });
}
