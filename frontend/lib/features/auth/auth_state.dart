import 'dart:convert';
import 'dart:html';

import 'package:flutter/foundation.dart';

import '../../model/entity/user.dart';
import '../../utils/prefs.dart';
import 'auth_service.dart';

enum AuthEvent { register, login, logout }

enum AuthStatus { initial, authenticated, notauthenticated, failed }

enum LoginRegister { login, register }

class AuthState extends ChangeNotifier {
  final AuthService _service;

  User? _user;
  AuthEvent? _event;
  AuthStatus _status = AuthStatus.initial;
  bool _isLoading = false;
  String? _token;
  String _error = '';
  LoginRegister _loginRegsiter = LoginRegister.login;

  User? get user => _user;
  AuthEvent? get event => _event;
  AuthStatus get status => _status;
  String? get token => _token;
  String get error => _error;

  bool get isLogin => _loginRegsiter == LoginRegister.login;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get notAuthenticated => _status == AuthStatus.notauthenticated;
  bool get isFailed => _status == AuthStatus.failed;

  AuthState(this._service) {
    _event = null;
    _status = AuthStatus.initial;
    _isLoading = false;
    _loginRegsiter = LoginRegister.login;
    _error = '';
  }

  Future switchLoginRegister() async {
    if (_loginRegsiter == LoginRegister.login) {
      _loginRegsiter = LoginRegister.register;
      return;
    }
    _loginRegsiter = LoginRegister.login;
  }

  Future init() async {
    final user = await Prefs.getString('user');
    final token = await Prefs.getString('token');

    if (user != null) {
      _user = User.fromJson(jsonDecode(user));
    }

    if (token != null) {
      _token = token;
    }

    if (_user != null && _token != null) {
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.notauthenticated;
    }

    notifyListeners();
  }

  Future register(String username, String password) async {
    _event = AuthEvent.register;
    _isLoading = true;

    notifyListeners();

    try {
      final data = await _service.register(username, password);

      if (data is User && data.token.isNotEmpty) {
        _user = data;

        await Prefs.setString('user', jsonEncode(user!.toJson()));
        await Prefs.setString('token', data.token);

        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.notauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.failed;
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future login(String username, String password) async {
    _event = AuthEvent.login;
    _isLoading = true;

    notifyListeners();

    try {
      final data = await _service.login(username, password);

      if (data is User && data.token.isNotEmpty) {
        _user = data;

        await Prefs.setString('user', jsonEncode(user!.toJson()));
        await Prefs.setString('token', data.token);

        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.notauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.failed;
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future logout() async {
    _event = AuthEvent.logout;
    _isLoading = true;

    notifyListeners();

    await Prefs.remove('user');
    await Prefs.remove('token');

    _status = AuthStatus.initial;
    _error = '';
    _event = null;
    _user = null;
    _token = null;
    _isLoading = false;

    notifyListeners();
  }
}
