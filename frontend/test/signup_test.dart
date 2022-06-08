import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_web_server/mock_web_server.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storystains/common/http/dio_manager.dart';
import 'package:storystains/common/util/auth_manager.dart';
import 'package:storystains/common/util/init_utils.dart';
import 'package:storystains/model/entity/user.dart';
import 'package:storystains/model/req/add_user.dart';
import 'package:storystains/model/resp/user_resp.dart';
import 'package:storystains/pages/login_or_register/logic.dart';
import 'package:storystains/services/rest_client.dart';

late MockWebServer _server;
late RestClient _client;

final _headers = {"Content-Type": "application/json"};
void main() {
  setUp(() async {
    _server = MockWebServer();
    await _server.start();

    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await InitUtils.init().then((value) => null);
    getItSetUp();

    _client = RestClient(sl<DioManager>().dio, baseUrl: _server.url);

    sl.unregister<RestClient>();
    sl.registerSingleton<RestClient>(_client);
  });

  tearDown(() {
    _server.shutdown();
  });

  group("signup", () {
    test('returns an User if the http call completes successfully', () async {
      // Use Mockito to return a successful response when it calls the
      // provided Client
      const username = "username";
      const password = "password";
      final addUser =
          AddUser(user: NewUser(username: "username", password: "password"));
      final user = User(token: "token", username: username);
      final userResp = UserResp(user: user);

      _server.enqueue(body: jsonEncode(userResp), headers: _headers);

      final userR = await sl<RestClient>().addUser(addUser);

      expect(userR.user.username, username);

      _server.enqueue(body: jsonEncode(userResp), headers: _headers);
      final state = LoginOrRegisterLogic();
      state.nameController.text = username;
      state.passwordController.text = password;
      state.signUp();

      expect(sl<AuthManager>().user, user);
      expect(sl<AuthManager>().token, "token");
      expect(sl<AuthManager>().isLogin, true);
    });
    test('auth manager successfully stores user to be logged in', () async {
      WidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      await InitUtils.init();
      getItSetUp();

      sl<AuthManager>().login(User(username: "username", token: "token"));
      expect(sl<AuthManager>().isLogin, true);
    });
  });
}

// TODO Test Signup
// TODO Test handle signup error
// TODO Test Login
// TODO Test handle login error
// TODO Test Logout
// TODO Test handle logout error
