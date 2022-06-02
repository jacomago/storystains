import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:storystains/utils/utils.dart';

import '../../models/review.dart';
import 'review_service.dart';

enum ReviewEvent { add, update, delete }

enum ReviewStatus { initial, open, changed, notChanged, failed }

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
  bool get isChanged => _status == ReviewStatus.changed;
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

  Future add(EditReview review) async {
    _event = ReviewEvent.add;
    _isLoading = true;

    notifyListeners();

    try {
      final data = await _service.add(review);

      if (data is Map && data.containsKey('review')) {
        _review = Review.fromJson(data['review']);

        await Prefs.setString('review', jsonEncode(review.toJson()));

        _status = ReviewStatus.changed;
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

  Future update(EditReview review) async {
    _event = ReviewEvent.update;
    _isLoading = true;

    notifyListeners();

    try {
      final data = await _service.update(review);

      if (data is Map && data.containsKey('review')) {
        _review = Review.fromJson(data['review']);

        await Prefs.setString('review', jsonEncode(review!.toJson()));
        await Prefs.setString('token', data['review']['token']);

        _status = ReviewStatus.changed;
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
}
