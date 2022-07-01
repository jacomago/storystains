import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storystains/common/utils/service_locator.dart';
import 'package:storystains/common/utils/utils.dart';
import 'package:storystains/features/auth/auth.dart';
import 'package:mockito/annotations.dart';

import '../../common/errors.dart';
import 'user.dart';
import 'auth_test.mocks.dart';

// In none widget tests secure storage doesn't work
// So we must mock it for this test
// In this case we wrap around SharedPreferences instead
class FakeSecureStorage extends Fake implements FlutterSecureStorage {
  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) =>
      Prefs.setString(key, value!);

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) =>
      Prefs.getString(key);

  @override
  Future<bool> containsKey({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) =>
      Prefs.containsKey(key);

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) =>
      Prefs.remove(key);
}

@GenerateMocks([AuthService])
void main() {
  setUp(() {
    WidgetsFlutterBinding.ensureInitialized();
    sl.registerSingleton<FlutterSecureStorage>(FakeSecureStorage());
  });
  tearDown(() {
    sl.reset();
  });
  group("login", () {
    test('After logging in isAuthenticated', () async {
      SharedPreferences.setMockInitialValues({});

      const password = "password";
      final user = testUser();
      final userResp = UserResp(user: user);

      final mockService = MockAuthService();
      final authState = AuthState(mockService);

      expect(authState.isAuthenticated, false);

      when(mockService.login(user.username, password))
          .thenAnswer((realInvocation) async => userResp);

      await authState.loginRegister(user.username, password);

      verify(mockService.login(user.username, password));
      expect(authState.isAuthenticated, true);
    });
    test('error message on bad info', () async {
      final mockService = MockAuthService();
      final authState = AuthState(mockService);

      expect(authState.isAuthenticated, false);

      when(mockService.login("", ""))
          .thenThrow(testApiError(400, "Invalid info."));

      await authState.loginRegister("", "");

      verify(mockService.login("", ""));
      expect(authState.isAuthenticated, false);
      expect(authState.error, "Bad Request: Invalid info.");
    });
  });
  group("signup", () {
    test('After signup in isAuthenticated', () async {
      SharedPreferences.setMockInitialValues({});
      const password = "password";
      final user = testUser();
      final userResp = UserResp(user: user);

      final mockService = MockAuthService();
      final authState = AuthState(mockService);

      expect(authState.isAuthenticated, false);

      when(mockService.register(user.username, password))
          .thenAnswer((realInvocation) async => userResp);
      authState.switchLoginRegister();
      await authState.loginRegister(user.username, password);

      verify(mockService.register(user.username, password));
      expect(authState.isAuthenticated, true);
    });

    test('error message on bad info', () async {
      final mockService = MockAuthService();
      final authState = AuthState(mockService);

      expect(authState.isAuthenticated, false);

      when(mockService.register("", ""))
          .thenThrow(testApiError(400, "Invalid info."));
      authState.switchLoginRegister();

      await authState.loginRegister("", "");

      verify(mockService.register("", ""));
      expect(authState.isAuthenticated, false);
      expect(authState.error, "Bad Request: Invalid info.");
    });
  });
  group("logout", () {
    test('After logout not isAuthenticated', () async {
      SharedPreferences.setMockInitialValues({});
      const password = "password";
      final user = testUser();
      final userResp = UserResp(user: user);

      final mockService = MockAuthService();
      final authState = AuthState(mockService);

      expect(authState.isAuthenticated, false);

      when(mockService.register(user.username, password))
          .thenAnswer((realInvocation) async => userResp);
      authState.switchLoginRegister();

      await authState.loginRegister(user.username, password);

      verify(mockService.register(user.username, password));
      expect(authState.isAuthenticated, true);

      await authState.logout();
      expect(authState.isAuthenticated, false);
    });
  });
  group("delete", () {
    test('After logout not isAuthenticated', () async {
      SharedPreferences.setMockInitialValues({});
      const password = "password";
      final user = testUser();
      final userResp = UserResp(user: user);

      final mockService = MockAuthService();
      final authState = AuthState(mockService);

      expect(authState.isAuthenticated, false);

      when(mockService.register(user.username, password))
          .thenAnswer((realInvocation) async => userResp);
      authState.switchLoginRegister();

      await authState.loginRegister(user.username, password);

      when(mockService.delete()).thenAnswer((realInvocation) async => null);

      await authState.delete();
      verify(mockService.delete());
      expect(authState.isAuthenticated, false);
    });
  });
}
