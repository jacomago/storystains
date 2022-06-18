import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:storystains/common/data/network/api_exception.dart';
import 'package:storystains/common/utils/error.dart';
import 'package:storystains/model/resp/review_resp.dart';

import '../../model/entity/review.dart';
import 'review_service.dart';

enum ReviewEvent { read, update, delete }

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

  Review? get review => _review;
  ReviewEvent? get event => _event;
  ReviewStatus get status => _status;
  String? get token => _token;
  String get error => _error;
  bool get isCreate => _isCreate;

  bool get isLoading => _isLoading;
  bool get isUpdated => _status == ReviewStatus.updated;
  bool get notUpdated => _status == ReviewStatus.notupdated;
  bool get isFailed => _status == ReviewStatus.failed;

  late TextEditingController titleController;
  late TextEditingController bodyController;

  ReviewState(this._service, [Review? review]) {
    _event = null;
    _status = ReviewStatus.initial;
    _isLoading = false;
    _error = '';
    _isCreate = review == null;
    _review = review;
    titleController = TextEditingController(text: review?.title);
    bodyController = TextEditingController(text: review?.body);
  }

  Future putReview(Review review) async {
    _review = review;
    notifyListeners();
  }

  Future<void> init() async {
    _status = _review != null ? ReviewStatus.read : ReviewStatus.notupdated;

    notifyListeners();
  }

  Future read(String slug) async {
    _event = ReviewEvent.read;
    _isLoading = true;

    notifyListeners();

    try {
      final data = await _service.read(slug);

      if (data is ReviewResp) {
        _review = data.review;

        _status = ReviewStatus.read;
      } else {
        final e = StatusCodeException.exception(data);
        throw e;
      }
    } on DioError catch (e) {
      _status = ReviewStatus.failed;
      _error = errorMessage(e);
    } catch (e) {
      _status = ReviewStatus.failed;
    }

    _isLoading = false;
    notifyListeners();
  }


  Future update(String title, String body) async {
    _event = ReviewEvent.update;
    _isLoading = true;

    notifyListeners();

    try {
      final data = _isCreate
          ? await _service.create(title, body)
          : await _service.update(_review!.slug, title, body);

      if (data is ReviewResp) {
        _review = data.review;

        _status = ReviewStatus.updated;
      } else {
        final e = StatusCodeException.exception(data);
        throw e;
      }
    } on DioError catch (e) {
      _status = ReviewStatus.failed;
      _error = errorMessage(e);
    } catch (e) {
      _status = ReviewStatus.failed;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future delete(slug) async {
    _event = ReviewEvent.delete;
    _isLoading = true;

    notifyListeners();

    try {
      final data = await _service.delete(slug);

      if (data is Response && data.statusCode == 200) {
        _review = null;

        _status = ReviewStatus.initial;
        _error = '';
        _event = null;
        _review = null;
        _token = null;
      } else {
        final e = StatusCodeException.exception(data);
        throw e;
      }
    } on DioError catch (e) {
      _status = ReviewStatus.failed;
      _error = errorMessage(e);
    } catch (e) {
      _status = ReviewStatus.failed;
      _error = e.toString();
    }

    _isLoading = false;

    notifyListeners();
  }
}
