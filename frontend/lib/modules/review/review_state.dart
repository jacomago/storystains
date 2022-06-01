import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:storystains/utils/utils.dart';

import '../../models/review.dart';
import 'review_service.dart';

enum ReviewEvent { add, update, delete }

enum ReviewStatus { initial, open, added, updated, notChanged, deleted, failed }

class ReviewState extends ChangeNotifier {
  final ReviewService _service;

  Review? _review;
  ReviewEvent? _event;
  ReviewStatus _status = ReviewStatus.initial;
  bool _isLoading = false;
  String _error = '';

  Review? get review => _review;
  ReviewEvent? get event => _event;
  ReviewStatus get status => _status;
  String get error => _error;

  bool get isLoading => _isLoading;
  bool get isOpen => _status == ReviewStatus.open;
  bool get isUpdated => _status == ReviewStatus.updated;
  bool get isCreated => _status == ReviewStatus.added;
  bool get isDeleted => _status == ReviewStatus.deleted;
  bool get isFailed => _status == ReviewStatus.failed;

  ReviewState(this._service) {
    _event = null;
    _status = ReviewStatus.initial;
    _isLoading = false;
    _error = '';
  }

  Future init() async {
    final review = await Prefs.getString('review');

    if (review != null) {
      _review = Review.fromJson(jsonDecode(review));
    }

    if (_review != null) {
      _status = ReviewStatus.open;
    } else {
      _status = ReviewStatus.notChanged;
    }

    notifyListeners();
  }

  Future add(Review review) async {
    _event = ReviewEvent.add;
    _isLoading = true;

    notifyListeners();

    try {
      final data = await _service.add(review);

      if (data is Map && data.containsKey('review')) {
        _review = Review.fromJson(data['review']);

        await Prefs.setString('review', jsonEncode(review.toJson()));

        _status = ReviewStatus.added;
      } else {
        _status = ReviewStatus.notChanged;
      }
    } catch (e) {
      _status = ReviewStatus.failed;
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future update(Review review) async {
    _event = ReviewEvent.update;
    _isLoading = true;

    notifyListeners();

    try {
      final data = await _service.update(review);

      if (data is Map && data.containsKey('review')) {
        _review = Review.fromJson(data['review']);

        await Prefs.setString('review', jsonEncode(review!.toJson()));
        await Prefs.setString('token', data['review']['token']);

        _status = ReviewStatus.updated;
      } else {
        _status = ReviewStatus.notChanged;
      }
    } catch (e) {
      _status = ReviewStatus.failed;
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future delete(Review review) async {
    _event = ReviewEvent.delete;
    _isLoading = true;

    notifyListeners();

    try {
      final data = await _service.delete(review);

      _review = Review.fromJson(data['review']);

      await Prefs.remove('review');

      _status = ReviewStatus.initial;
      _error = '';
      _event = null;
      _review = null;
      _isLoading = false;

      _status = ReviewStatus.deleted;
    } catch (e) {
      _status = ReviewStatus.failed;
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}
