import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../common/utils/error.dart';
import '../story/story.dart';
import 'review.dart';

enum ReviewEvent { read, update, delete }

enum ReviewStatus { initial, read, updated, deleted, failed }

enum ReviewStateType { edit, create, read }

class ReviewState extends ChangeNotifier {
  final ReviewService _service;

  Review? _review;
  ReviewEvent? _event;
  ReviewStatus _status = ReviewStatus.initial;
  ReviewStateType? _stateType;
  bool _isLoading = false;
  String? _token;
  String _error = '';

  Review? get review => _review;
  ReviewEvent? get event => _event;
  ReviewStatus get status => _status;
  ReviewStateType? get stateType => _stateType;
  String? get token => _token;
  String get error => _error;

  bool get isCreate => _stateType == ReviewStateType.create;
  bool get isEdit => _stateType != ReviewStateType.read;

  bool get isLoading => _isLoading;
  bool get isUpdated => _status == ReviewStatus.updated;
  bool get isDeleted => _status == ReviewStatus.deleted;
  bool get isFailed => _status == ReviewStatus.failed;

  late StoryState storyContoller;
  late TextEditingController bodyController;

  ReviewState(this._service, {Review? review, ReviewRoutePath? path}) {
    _event = null;
    _status = ReviewStatus.initial;
    _isLoading = false;
    _error = '';

    _stateType = (review == null && path == null)
        ? ReviewStateType.create
        : ReviewStateType.read;
    _review = review;
    storyContoller = StoryState(StoryService(), story: review?.story);
    bodyController = TextEditingController(text: review?.body);

    if (path != null) {
      _init(path);
    }
  }

  void edit() {
    _stateType = ReviewStateType.edit;
    notifyListeners();
  }

  void unEdit() {
    _stateType = ReviewStateType.read;
    notifyListeners();
  }

  Future<void> _init(ReviewRoutePath path) async {
    _startLoading();

    try {
      final data = await _service.read(path.username, path.slug);

      _review = data.review;

      storyContoller = StoryState(StoryService(), story: review?.story);
      bodyController = TextEditingController(text: _review?.body);
      _status = ReviewStatus.read;
      _stateType = ReviewStateType.read;
    } on DioError catch (e) {
      _status = ReviewStatus.failed;
      _error = errorMessage(e);
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

  Future<void> update(Story story, String body) async {
    _event = ReviewEvent.update;
    _isLoading = true;

    notifyListeners();

    try {
      final data = isCreate
          ? await _service.create(story, body)
          : await _service.update(
              _review!.user.username,
              _review!.slug,
              story,
              body,
            );

      _review = data.review;

      _status = ReviewStatus.updated;
      _stateType = ReviewStateType.read;
    } on DioError catch (e) {
      _status = ReviewStatus.failed;
      _error = errorMessage(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> delete() async {
    _event = ReviewEvent.delete;
    _isLoading = true;

    notifyListeners();

    try {
      await _service.delete(_review!.user.username, _review!.slug);

      _review = null;

      _status = ReviewStatus.deleted;
      _stateType = null;
      _error = '';
      _event = null;
      _review = null;
      _token = null;
    } on DioError catch (e) {
      _status = ReviewStatus.failed;
      _error = errorMessage(e);
    }

    _isLoading = false;

    notifyListeners();
  }
}
