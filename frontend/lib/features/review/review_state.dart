import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../model/entity/review.dart';
import '../../utils/prefs.dart';
import 'review_service.dart';

enum ReviewEvent { create, read, update, delete }

enum ReviewStatus { initial, read, updated, notupdated, failed }

class ReviewState extends ChangeNotifier {
  final ReviewService _service;

  Review? _review;
  ReviewEvent? _event;
  ReviewStatus _status = ReviewStatus.initial;
  bool _isLoading = false;
  String? _token;
  String _error = '';
  bool _isCreate = true;
  String _slug = "";

  Review? get review => _review;
  ReviewEvent? get event => _event;
  ReviewStatus get status => _status;
  String? get token => _token;
  String get error => _error;
  bool get isCreate => _isCreate;
  String get slug => _slug;

  bool get isLoading => _isLoading;
  bool get isUpdated => _status == ReviewStatus.updated;
  bool get notUpdated => _status == ReviewStatus.notupdated;
  bool get isFailed => _status == ReviewStatus.failed;

  ReviewState(this._service, [String slug = ""]) {
    _event = null;
    _status = ReviewStatus.initial;
    _isLoading = false;
    _error = '';
    _isCreate = slug.isEmpty;
    _slug = slug;
  }

  Future<void> init() async {
    var review;

    if (!_isCreate) {
      _isLoading = true;

      review = await _service.read(_slug);

      _isLoading = false;
    }

    if (review != null) {
      _review = review;
      _isCreate = false;
    }

    if (_review != null) {
      _status = ReviewStatus.read;
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

      if (data is Review) {
        _review = data;

        await Prefs.setString('review', jsonEncode(review!.toJson()));

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

  Future update(String title, String body) async {
    _event = ReviewEvent.update;
    _isLoading = true;

    notifyListeners();

    try {
      final data = await _service.update(_review!.slug, title, body);

      if (data is Review) {
        _review = data;

        await Prefs.setString('review', jsonEncode(review!.toJson()));

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

  Future delete() async {
    _event = ReviewEvent.delete;
    _isLoading = true;

    notifyListeners();

    await Prefs.remove('review');

    _status = ReviewStatus.initial;
    _error = '';
    _event = null;
    _review = null;
    _token = null;
    _isLoading = false;

    notifyListeners();
  }
}
