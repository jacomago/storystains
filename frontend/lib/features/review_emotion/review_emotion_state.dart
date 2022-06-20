import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:storystains/common/data/network/api_exception.dart';
import 'package:storystains/common/utils/error.dart';
import 'package:storystains/model/entity/emotion.dart';
import 'package:storystains/model/resp/review_emotion_resp.dart';

import '../../model/entity/review_emotion.dart';
import 'review_emotion_service.dart';

enum ReviewEmotionEvent { create, read, update, delete }

enum ReviewEmotionStatus { initial, read, updated, notupdated, failed }

class ReviewEmotionState extends ChangeNotifier {
  final ReviewEmotionService _service;

  ReviewEmotion? _reviewEmotion;
  ReviewEmotionEvent? _event;
  ReviewEmotionStatus _status = ReviewEmotionStatus.initial;
  bool _isLoading = false;
  String? _token;
  String _error = '';
  bool _isCreate = true;

  ReviewEmotion? get reviewEmotion => _reviewEmotion;
  ReviewEmotionEvent? get event => _event;
  ReviewEmotionStatus get status => _status;
  String? get token => _token;
  String get error => _error;
  bool get isCreate => _isCreate;

  bool get isLoading => _isLoading;
  bool get isUpdated => _status == ReviewEmotionStatus.updated;
  bool get notUpdated => _status == ReviewEmotionStatus.notupdated;
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

  Future putReviewEmotion(ReviewEmotion reviewEmotion) async {
    _reviewEmotion = reviewEmotion;
    notifyListeners();
  }

  Future<void> init() async {
    _status = _reviewEmotion != null
        ? ReviewEmotionStatus.read
        : ReviewEmotionStatus.notupdated;

    notifyListeners();
  }

  Future read(String slug, int position) async {
    _event = ReviewEmotionEvent.read;
    _isLoading = true;

    notifyListeners();

    try {
      final data = await _service.read(slug, position);

      if (data is ReviewEmotionResp) {
        _reviewEmotion = data.reviewEmotion;

        _status = ReviewEmotionStatus.read;
      } else {
        final e = StatusCodeException.exception(data);
        throw e;
      }
    } on DioError catch (e) {
      _status = ReviewEmotionStatus.failed;
      _error = errorMessage(e);
    } catch (e) {
      _status = ReviewEmotionStatus.failed;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future update(
    String slug,
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
              slug,
              updateReviewEmotion,
            )
          : await _service.update(
              slug,
              _reviewEmotion!.position,
              updateReviewEmotion,
            );

      if (data is ReviewEmotionResp) {
        _reviewEmotion = data.reviewEmotion;

        _status = ReviewEmotionStatus.updated;
      } else {
        final e = StatusCodeException.exception(data);
        throw e;
      }
    } on DioError catch (e) {
      _status = ReviewEmotionStatus.failed;
      _error = errorMessage(e);
    } catch (e) {
      _status = ReviewEmotionStatus.failed;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future delete(String slug, int position) async {
    _event = ReviewEmotionEvent.delete;
    _isLoading = true;

    notifyListeners();

    try {
      final data = await _service.delete(slug, position);

      if (data is Response && data.statusCode == 200) {
        _reviewEmotion = null;

        _status = ReviewEmotionStatus.initial;
        _error = '';
        _event = null;
        _reviewEmotion = null;
        _token = null;
      } else {
        final e = StatusCodeException.exception(data);
        throw e;
      }
    } on DioError catch (e) {
      _status = ReviewEmotionStatus.failed;
      _error = errorMessage(e);
    } catch (e) {
      _status = ReviewEmotionStatus.failed;
      _error = e.toString();
    }

    _isLoading = false;

    notifyListeners();
  }
}
