// Mocks generated by Mockito 5.2.0 from annotations
// in storystains/test/features/auth/auth_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i4;

import 'package:mockito/mockito.dart' as _i1;
import 'package:storystains/features/auth/auth_model.dart' as _i2;
import 'package:storystains/features/auth/auth_service.dart' as _i3;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types

class _FakeUserResp_0 extends _i1.Fake implements _i2.UserResp {}

/// A class which mocks [AuthService].
///
/// See the documentation for Mockito's code generation for more information.
class MockAuthService extends _i1.Mock implements _i3.AuthService {
  MockAuthService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Future<_i2.UserResp> register(String? username, String? password) =>
      (super.noSuchMethod(Invocation.method(#register, [username, password]),
              returnValue: Future<_i2.UserResp>.value(_FakeUserResp_0()))
          as _i4.Future<_i2.UserResp>);
  @override
  _i4.Future<_i2.UserResp> login(String? username, String? password) =>
      (super.noSuchMethod(Invocation.method(#login, [username, password]),
              returnValue: Future<_i2.UserResp>.value(_FakeUserResp_0()))
          as _i4.Future<_i2.UserResp>);
  @override
  _i4.Future<void> delete() =>
      (super.noSuchMethod(Invocation.method(#delete, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i4.Future<void>);
}
