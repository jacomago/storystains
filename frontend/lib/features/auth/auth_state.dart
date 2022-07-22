import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../common/utils/utils.dart';

import '../user/user_model.dart';
import 'auth.dart';

/// Events of authentication
enum AuthEvent {
  /// Register
  register,

  /// Login
  login,

  /// Logout
  logout,

  /// Delete
  delete
}

/// Status of Auth State
enum AuthStatus {
  /// Starting
  initial,

  /// Authenticated (have a cookie)
  authenticated,

  /// Not auth
  notauthenticated,

  /// user deleted
  deleted,

  /// Failed action
  failed
}

/// wether ready to login or register
enum LoginRegister {
  /// to login
  login,

  /// to register
  register
}

/// representation of the users authentiction status
class AuthState extends ChangeNotifier {
  final AuthService _service;

  User? _user;
  AuthEvent? _event;
  AuthStatus _status = AuthStatus.initial;
  bool _isLoading = false;
  String _error = '';
  LoginRegister _loginRegister = LoginRegister.login;

  /// Get current user
  User? get user => _user;

  /// Get user profile of logged in user
  UserProfile? get userProfile =>
      _user == null ? null : UserProfile(username: _user!.username);

  /// current event
  AuthEvent? get event => _event;

  /// Current status
  AuthStatus get status => _status;

  /// Any error message
  String get error => _error;

  /// Whether to login or register
  bool get isLogin => _loginRegister == LoginRegister.login;

  /// Still loading
  bool get isLoading => _isLoading;

  /// if authenticated
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  /// if not authenticated
  bool get notAuthenticated => _status == AuthStatus.notauthenticated;

  /// if failed
  bool get isFailed => _status == AuthStatus.failed;

  /// representation of the users authentiction status
  AuthState(
    this._service,
  ) {
    _event = null;
    _status = AuthStatus.initial;
    _isLoading = false;
    _loginRegister = LoginRegister.login;
    _error = '';
    init();
  }

  /// Swtich between loggin in or registering
  void switchLoginRegister() {
    _loginRegister = _loginRegister == LoginRegister.login
        ? LoginRegister.register
        : LoginRegister.login;
    notifyListeners();
  }

  /// if same user as another user profile
  bool sameUser(UserProfile other) => _user?.username == other.username;

  /// load ton from secure storage on start
  Future<void> init() async {
    _isLoading = true;

    notifyListeners();

    try {
      final data = await _service.getUser();

      if (data.user.username.isNotEmpty) {
        _user = data.user;

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

  /// Login or register via api
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

      if (data.user.username.isNotEmpty) {
        _user = data.user;

        _status = AuthStatus.authenticated;
        _error = '';
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

  /// delete the current user
  Future<void> delete() async {
    _event = AuthEvent.delete;
    _isLoading = true;

    notifyListeners();

    try {
      await _service.delete();

      _status = AuthStatus.deleted;
      _error = '';
      _event = null;
      _user = null;
      _isLoading = false;
    } on DioError catch (e) {
      _status = AuthStatus.failed;
      _error = errorMessage(e);
    }

    notifyListeners();
  }

  /// Logout from the application
  Future<void> logout() async {
    _event = AuthEvent.logout;
    _isLoading = true;

    notifyListeners();

    try {
      await _service.logout();

      _status = AuthStatus.initial;
      _error = '';
      _event = null;
      _user = null;
      _isLoading = false;
    } on DioError catch (e) {
      _status = AuthStatus.failed;
      _error = errorMessage(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _error = '';
    _event = null;
    _status = AuthStatus.initial;
    _user = null;
    _isLoading = false;
    super.dispose();
  }
}
