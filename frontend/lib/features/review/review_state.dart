import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../common/utils/error.dart';
import '../review_emotions/review_emotions_state.dart';
import '../story/story.dart';
import '../user/user_model.dart';
import 'review.dart';

/// Events on [Review]
enum ReviewEvent {
  /// read from api
  read,

  /// update to api
  update,

  /// copy locally
  copy,

  /// delete via api
  delete
}

/// status of state
enum ReviewStatus {
  /// load
  initial,

  /// read from url
  read,

  /// updated to api
  updated,

  /// deleted from api
  deleted,

  /// failed action
  failed
}

/// state type
enum ReviewStateType {
  /// Editing the review
  edit,

  /// creating a new review (not in api)
  create,

  /// reading from url
  read
}

///
/// State of editing or showing a [Review]
class ReviewState extends ChangeNotifier {
  final ReviewService _service;

  Review? _review;
  ReviewEvent? _event;
  ReviewStatus _status = ReviewStatus.initial;
  ReviewStateType? _stateType;
  bool _isLoading = false;
  String _error = '';

  /// current fromapi
  Review? get review => _review;

  /// event
  ReviewEvent? get event => _event;

  /// status
  ReviewStatus get status => _status;

  /// type of state
  ReviewStateType? get stateType => _stateType;

  /// error message
  String get error => _error;

  /// if in create mode
  bool get isCreate => _stateType == ReviewStateType.create;

  /// if inedit mode
  bool get isEdit => _stateType != ReviewStateType.read;

  /// if laoding from api
  bool get isLoading => _isLoading;

  /// if updated
  bool get isUpdated => _status == ReviewStatus.updated;

  /// if delted
  bool get isDeleted => _status == ReviewStatus.deleted;

  /// if failed
  bool get isFailed => _status == ReviewStatus.failed;

  /// controller for editing story
  late StoryState storyController;

  /// controller for editing body
  late TextEditingController bodyController;

  /// controller for editing Review Emotions
  late ReviewEmotionsState reviewEmotionsController;

  /// State of editing or showing a [Review]
  ReviewState(this._service, {Review? review, ReviewRoutePath? path}) {
    _event = null;
    _status = ReviewStatus.initial;
    _isLoading = false;
    _error = '';

    _stateType = (review == null && path == null)
        ? ReviewStateType.create
        : ReviewStateType.read;
    _review = review;
    storyController = StoryState(StoryService(), story: review?.story);
    bodyController = TextEditingController(text: review?.body);
    reviewEmotionsController = ReviewEmotionsState(review?.emotions);

    if (path != null) {
      _init(path);
    }
  }

  /// switch to edit mode
  void edit() {
    _stateType = ReviewStateType.edit;
    notifyListeners();
  }

  /// switch out of edit mode
  void unEdit() {
    _stateType = ReviewStateType.read;
    notifyListeners();
  }

  /// load from apif
  Future<void> _init(ReviewRoutePath path) async {
    _startLoading();

    try {
      final data = await _service.read(path.username, path.slug);

      _review = data.review;

      storyController = StoryState(StoryService(), story: review?.story);
      bodyController = TextEditingController(text: _review?.body);
      reviewEmotionsController = ReviewEmotionsState(_review?.emotions);
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

  /// update to api
  Future<void> update(Story? story, String? body) async {
    _event = ReviewEvent.update;
    _isLoading = true;

    notifyListeners();

    try {
      final data = isCreate
          ? await _service.create(story!, body)
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

  /// delte review
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
      bodyController.clear();
      storyController.clear();
      reviewEmotionsController.clear();
    } on DioError catch (e) {
      _status = ReviewStatus.failed;
      _error = errorMessage(e);
    }

    _isLoading = false;

    notifyListeners();
  }

  /// copy current review with story
  Future<void> copy(String username) async {
    _event = ReviewEvent.copy;
    _isLoading = true;

    notifyListeners();

    _status = ReviewStatus.initial;

    _stateType = ReviewStateType.create;
    final review = Review(
      body: '',
      createdAt: DateTime.now(),
      slug: '',
      story: _review!.story,
      updatedAt: DateTime.now(),
      emotions: [],
      user: UserProfile(username: username),
    );

    _review = review;
    storyController = StoryState(StoryService(), story: review.story);
    bodyController = TextEditingController(text: review.body);
    reviewEmotionsController = ReviewEmotionsState([]);

    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    bodyController.dispose();
    storyController.dispose();
    _error = '';
    _event = null;
    _stateType = null;
    _status = ReviewStatus.initial;
    _review = null;
    _isLoading = false;
    super.dispose();
  }
}
