import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../common/utils/error.dart';
import '../emotions/emotion_model.dart';
import '../review/review_model.dart';
import 'review_emotion_model.dart';

import 'review_emotion_service.dart';

enum ReviewEmotionEvent { create, read, update, delete }

enum ReviewEmotionStatus { initial, read, updated, deleted, failed }

class ReviewEmotionState extends ChangeNotifier {
  final ReviewEmotionService _service;

  ReviewEmotion? _reviewEmotion;
  ReviewEmotionEvent? _event;
  ReviewEmotionStatus _status = ReviewEmotionStatus.initial;
  bool _isLoading = false;
  String _error = '';
  bool _isCreate = true;

  ReviewEmotion? get reviewEmotion => _reviewEmotion;
  ReviewEmotionEvent? get event => _event;
  ReviewEmotionStatus get status => _status;
  String get error => _error;
  bool get isCreate => _isCreate;

  bool get isLoading => _isLoading;
  bool get isUpdated => _status == ReviewEmotionStatus.updated;
  bool get isDeleted => _status == ReviewEmotionStatus.deleted;
  bool get isFailed => _status == ReviewEmotionStatus.failed;

  late TextEditingController notesController;
  late ValueNotifier<int> positionController;
  late ValueNotifier<Emotion> emotionController;

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
    positionController = ValueNotifier(_isCreate ? 0 : reviewEmotion!.position);
    emotionController = ValueNotifier(emotion ?? reviewEmotion!.emotion);
  }

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
}
