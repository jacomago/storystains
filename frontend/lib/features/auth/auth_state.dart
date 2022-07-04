import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../common/utils/utils.dart';

import 'auth.dart';

enum AuthEvent { register, login, logout, delete }

enum AuthStatus { initial, authenticated, notauthenticated, deleted, failed }

enum LoginRegister { login, register }

class AuthState extends ChangeNotifier {
  final AuthService _service;

  User? _user;
  AuthEvent? _event;
  AuthStatus _status = AuthStatus.initial;
  bool _isLoading = false;
  String? _token;
  String _error = '';
  LoginRegister _loginRegister = LoginRegister.login;

  User? get user => _user;
  AuthEvent? get event => _event;
  AuthStatus get status => _status;
  String? get token => _token;
  String get error => _error;

  bool get isLogin => _loginRegister == LoginRegister.login;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get notAuthenticated => _status == AuthStatus.notauthenticated;
  bool get isFailed => _status == AuthStatus.failed;

  AuthState(this._service) {
    _event = null;
    _status = AuthStatus.initial;
    _isLoading = false;
    _loginRegister = LoginRegister.login;
    _error = '';
  }

  void switchLoginRegister() {
    _loginRegister = _loginRegister == LoginRegister.login
        ? LoginRegister.register
        : LoginRegister.login;
    notifyListeners();
  }

  bool sameUser(UserProfile other) => _user?.username == other.username;

  Future<void> init() async {
    final user = await AuthStorage.getUser();

    if (user != null) {
      _user = user;
      _token = user.token;
    }

    _status =
        _user != null ? AuthStatus.authenticated : AuthStatus.notauthenticated;

    notifyListeners();
  }

  Future<void> loginRegister(String username, String password) async {
    _event = _loginRegister == LoginRegister.login
        ? AuthEvent.login
        : AuthEvent.register;
    _isLoading = true;

    notifyListeners();

    try {
      final data = _loginRegister == LoginRegister.login
          ? await _service.login(username, password)
          : await _service.register(username, password);

      if (data.user.token.isNotEmpty) {
        _user = data.user;

        AuthStorage.login(_user!);

        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.notauthenticated;
      }
    } on DioError catch (e) {
      _status = AuthStatus.failed;
      _error = errorMessage(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> delete() async {
    _event = AuthEvent.delete;
    _isLoading = true;

    notifyListeners();

    try {
      await _service.delete();
      AuthStorage.logout();

      _status = AuthStatus.deleted;
      _error = '';
      _event = null;
      _user = null;
      _token = null;
      _isLoading = false;
    } on DioError catch (e) {
      _status = AuthStatus.failed;
      _error = errorMessage(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    _event = AuthEvent.logout;
    _isLoading = true;

    notifyListeners();

    AuthStorage.logout();

    _status = AuthStatus.initial;
    _error = '';
    _event = null;
    _user = null;
    _token = null;
    _isLoading = false;

    notifyListeners();
  }
}
