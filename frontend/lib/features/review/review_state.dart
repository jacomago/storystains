import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../model/entity/user.dart';
import '../../utils/prefs.dart';
import 'review_service.dart';

enum ReviewEvent { create, read, update, delete }

enum ReviewStatus { initial, updated, notupdated, failed }

class ReviewState extends ChangeNotifier {
  final ReviewService _service;

  User? _user;
  ReviewEvent? _event;
  ReviewStatus _status = ReviewStatus.initial;
  bool _isLoading = false;
  String? _token;
  String _error = '';

  User? get user => _user;
  ReviewEvent? get event => _event;
  ReviewStatus get status => _status;
  String? get token => _token;
  String get error => _error;

  bool get isLoading => _isLoading;
  bool get isUpdated => _status == ReviewStatus.updated;
  bool get notUpdated => _status == ReviewStatus.notupdated;
  bool get isFailed => _status == ReviewStatus.failed;

  ReviewState(this._service) {
    _event = null;
    _status = ReviewStatus.initial;
    _isLoading = false;
    _error = '';
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
      _status = ReviewStatus.updated;
    } else {
      _status = ReviewStatus.notupdated;
    }

    notifyListeners();
  }

  Future create(String title, String body) async {
    _event = ReviewEvent.create;
    _isLoading = true;

    notifyListeners();

    try {
      final data = await _service.create(title, body);

      if (data is User && data.token.isNotEmpty) {
        _user = data;

        await Prefs.setString('user', jsonEncode(user!.toJson()));
        await Prefs.setString('token', data.token);

        _status = ReviewStatus.updated;
      } else {
        _status = ReviewStatus.notupdated;
      }
    } catch (e) {
      _status = ReviewStatus.failed;
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future update(String slug, String title, String body) async {
    _event = ReviewEvent.update;
    _isLoading = true;

    notifyListeners();

    try {
      final data = await _service.update(slug, title, body);

      if (data is User && data.token.isNotEmpty) {
        _user = data;

        await Prefs.setString('user', jsonEncode(user!.toJson()));
        await Prefs.setString('token', data.token);

        _status = ReviewStatus.updated;
      } else {
        _status = ReviewStatus.notupdated;
      }
    } catch (e) {
      _status = ReviewStatus.failed;
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future logout() async {
    _event = ReviewEvent.delete;
    _isLoading = true;

    notifyListeners();

    await Prefs.remove('user');
    await Prefs.remove('token');

    _status = ReviewStatus.initial;
    _error = '';
    _event = null;
    _user = null;
    _token = null;
    _isLoading = false;

    notifyListeners();
  }
}
