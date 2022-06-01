import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:storystains/config/config.dart';
import 'package:storystains/modules/auth/auth.dart';

import 'auth_test.mocks.dart';

@GenerateMocks([http.Client])
void main() async {
  group('basic auth', () {
    test('starts not logged in', () async {
      final authService = AuthService();
      final authState = AuthState(authService);

      expect(authState.isAuthenticated, false);
    });

    test('logging in', () async {
      final authService = AuthService();
      final authState = AuthState(authService);
      final client = MockClient();

      when(client.post(Uri.parse('$baseUrl/login'))).thenAnswer((_) async =>
          http.Response('{"user":{"username":"user", "token": "token"}}', 200));
      await authState.login("user", "password");

      expect(authState.isAuthenticated, true);
    });
  });
}
