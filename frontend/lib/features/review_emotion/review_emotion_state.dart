import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../common/utils/error.dart';
import '../emotions/emotion_model.dart';
import '../review/review_model.dart';
import 'review_emotion_model.dart';

import 'review_emotion_service.dart';

/// Events the State can be doing
enum ReviewEmotionEvent {
  /// create review emotion
  create,

  /// read
  read,

  /// update
  update,

  /// delete
  delete
}

/// Statues the review emotion could be in
enum ReviewEmotionStatus {
  /// starting up
  initial,

  /// read the emotion from api
  read,

  /// udpated the emotion
  updated,

  /// delete the emotion
  deleted,

  /// failed an action
  failed
}

/// State of editing a review emtoion
class ReviewEmotionState extends ChangeNotifier {
  final ReviewEmotionService _service;

  ReviewEmotion? _reviewEmotion;
  ReviewEmotionEvent? _event;
  ReviewEmotionStatus _status = ReviewEmotionStatus.initial;
  bool _isLoading = false;
  String _error = '';
  bool _isCreate = true;

  /// current emotion
  ReviewEmotion? get reviewEmotion => _reviewEmotion;

  /// current event
  ReviewEmotionEvent? get event => _event;

  /// status of state
  ReviewEmotionStatus get status => _status;

  /// error message
  String get error => _error;

  /// if creating and not editing already uploaded review emotion
  bool get isCreate => _isCreate;

  /// If the emotion is still loading
  bool get isLoading => _isLoading;

  /// If the review emotion has been updated
  bool get isUpdated => _status == ReviewEmotionStatus.updated;

  /// If the review emotion has been deleted
  bool get isDeleted => _status == ReviewEmotionStatus.deleted;

  /// If the review emotion has failed
  bool get isFailed => _status == ReviewEmotionStatus.failed;

  /// Contoller for the notes
  late TextEditingController notesController;

  /// Controller for the position
  late ValueNotifier<int> positionController;

  /// Controller for the emotion
  late ValueNotifier<Emotion> emotionController;

  /// Create the state
  ReviewEmotionState(
    this._service, {
    ReviewEmotion? reviewEmotion,
    Emotion? emotion,
  }) {
    _event = null;
    _status = ReviewEmotionStatus.initial;
    _isLoading = false;
    _error = '';
    _isCreate = reviewEmotion == null;
    _reviewEmotion = reviewEmotion;

    notesController = TextEditingController(text: reviewEmotion?.notes);
    positionController = ValueNotifier(_isCreate ? 50 : reviewEmotion!.position);
    emotionController = ValueNotifier(emotion ?? reviewEmotion!.emotion);
  }

  /// Update the review emotion
  Future<void> update(
    Review review,
  ) async {
    _event = ReviewEmotionEvent.update;
    _isLoading = true;

    notifyListeners();

    try {
      final notes = notesController.value.text;
      final position = positionController.value;
      final emotion = emotionController.value;

      final updateReviewEmotion = ReviewEmotion(
        emotion: emotion,
        position: position,
        notes: notes,
      );
      final data = _isCreate
          ? await _service.create(
              review,
              updateReviewEmotion,
            )
          : await _service.update(
              review,
              _reviewEmotion!.position,
              updateReviewEmotion,
            );

      _reviewEmotion = data.reviewEmotion;

      _status = ReviewEmotionStatus.updated;
    } on DioError catch (e) {
      _status = ReviewEmotionStatus.failed;
      _error = errorMessage(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Delete the review emotion
  Future<void> delete(
    Review review,
  ) async {
    _event = ReviewEmotionEvent.delete;
    _isLoading = true;

    notifyListeners();

    try {
      await _service.delete(review, _reviewEmotion!.position);

      _reviewEmotion = null;

      _status = ReviewEmotionStatus.deleted;
      _error = '';
      _event = null;
      _reviewEmotion = null;
    } on DioError catch (e) {
      _status = ReviewEmotionStatus.failed;
      _error = errorMessage(e);
    }

    _isLoading = false;

    notifyListeners();
  }

  @override
  void dispose() {
    notesController.dispose();
    emotionController.dispose();
    positionController.dispose();
    _error = '';
    _event = null;
    _isCreate = false;
    _status = ReviewEmotionStatus.initial;
    _reviewEmotion = null;
    _isLoading = false;
    super.dispose();
  }
}
