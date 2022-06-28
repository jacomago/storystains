import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:storystains/common/data/network/api_exception.dart';
import 'package:storystains/common/utils/error.dart';
import 'package:storystains/features/review/review.dart';

enum ReviewEvent { read, update, delete }

enum ReviewStatus { initial, read, updated, deleted, failed }

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
  bool get isDeleted => _status == ReviewStatus.deleted;
  bool get isFailed => _status == ReviewStatus.failed;

  late TextEditingController titleController;
  late TextEditingController bodyController;

  ReviewState(this._service, {Review? review, ReviewRoutePath? path}) {
    _event = null;
    _status = ReviewStatus.initial;
    _isLoading = false;
    _error = '';

    if (path != null) {
      _init(path);
    }

    _isCreate = review == null;
    _review = review;
    titleController = TextEditingController(text: review?.title);
    bodyController = TextEditingController(text: review?.body);
  }

  Future<void> _init(ReviewRoutePath path) async {
    _startLoading();

    try {
      final data = await _service.read(path.username, path.slug);

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

    notifyListeners();
    _stopLoading();
  }

  void _startLoading() {
    _isLoading = true;
    notifyListeners();
  }

  void _stopLoading() {
    _isLoading = false;
    notifyListeners();
  }

  Future putReview(Review review) async {
    _review = review;
    notifyListeners();
  }

  Future update(String title, String body) async {
    _event = ReviewEvent.update;
    _isLoading = true;

    notifyListeners();

    try {
      final data = _isCreate
          ? await _service.create(title, body)
          : await _service.update(
              _review!.user.username,
              _review!.slug,
              title,
              body,
            );

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

  Future delete() async {
    _event = ReviewEvent.delete;
    _isLoading = true;

    notifyListeners();

    try {
      await _service.delete(_review!.user.username, _review!.slug);

      _review = null;

      _status = ReviewStatus.deleted;
      _error = '';
      _event = null;
      _review = null;
      _token = null;
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
