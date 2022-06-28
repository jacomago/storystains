import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mockito/annotations.dart';
import 'package:storystains/features/review_emotion/review_emotion.dart';

import '../../common/errors.dart';
import '../review/review.dart';
import 'review_emotion.dart';
import 'review_emotion_test.mocks.dart';

void updateControllers(ReviewEmotionState state, ReviewEmotion reviewEmotion) {
  state.emotionController.value = reviewEmotion.emotion;
  state.positionController.value = reviewEmotion.position;
  state.notesController.text = reviewEmotion.notes;
}

@GenerateMocks([ReviewEmotionService])
void main() {
  setUp(() => {WidgetsFlutterBinding.ensureInitialized()});
  group("create", () {
    test('After create in isUpdated', () async {
      SharedPreferences.setMockInitialValues({});
      final reviewEmotion = testReviewEmotion();
      final reviewEmotionResp = ReviewEmotionResp(reviewEmotion: reviewEmotion);

      final mockService = MockReviewEmotionService();
      final reviewEmotionState = ReviewEmotionState(
        mockService,
        emotion: reviewEmotion.emotion,
      );

      expect(reviewEmotionState.isCreate, true);

      final review = testReview();
      when(mockService.create(review, reviewEmotion))
          .thenAnswer((realInvocation) async => reviewEmotionResp);

      updateControllers(reviewEmotionState, reviewEmotion);
      await reviewEmotionState.update(review);

      verify(mockService.create(review, reviewEmotion));
      expect(reviewEmotionState.isUpdated, true);
    });

    test('error message on bad info', () async {
      SharedPreferences.setMockInitialValues({});
      final reviewEmotion = testReviewEmotion();

      final mockService = MockReviewEmotionService();
      final reviewEmotionState = ReviewEmotionState(
        mockService,
        emotion: reviewEmotion.emotion,
      );

      expect(reviewEmotionState.isCreate, true);

      final review = testReview();
      when(mockService.create(
        review,
        reviewEmotion,
      )).thenThrow(testApiError(400, "Cannot be empty."));

      updateControllers(reviewEmotionState, reviewEmotion);
      await reviewEmotionState.update(review);

      verify(mockService.create(review, testReviewEmotion()));
      expect(reviewEmotionState.isUpdated, false);
      expect(reviewEmotionState.error, "Bad Request: Cannot be empty.");
    });

    test('error message on unauthorised info', () async {
      SharedPreferences.setMockInitialValues({});
      final reviewEmotion = testReviewEmotion();
      final mockService = MockReviewEmotionService();
      final reviewEmotionState = ReviewEmotionState(
        mockService,
        emotion: reviewEmotion.emotion,
      );

      expect(reviewEmotionState.isCreate, true);

      final review = testReview();
      when(mockService.create(
        review,
        reviewEmotion,
      )).thenThrow(testApiError(401, "User not logged in."));

      updateControllers(reviewEmotionState, reviewEmotion);
      await reviewEmotionState.update(
        review,
      );

      verify(mockService.create(review, reviewEmotion));
      expect(reviewEmotionState.isUpdated, false);
      expect(reviewEmotionState.error, "Unauthorised: User not logged in.");
    });
  });
  group("delete", () {
    test('After delete in initial', () async {
      SharedPreferences.setMockInitialValues({});
      final reviewEmotion = testReviewEmotion();

      final mockService = MockReviewEmotionService();

      final reviewEmotionState =
          ReviewEmotionState(mockService, reviewEmotion: reviewEmotion);

      expect(reviewEmotionState.isCreate, false);
      expect(reviewEmotionState.isUpdated, false);

      final review = testReview();
      when(mockService.delete(review, reviewEmotion.position)).thenAnswer(
        (realInvocation) async =>
            Response(requestOptions: RequestOptions(path: ""), statusCode: 200),
      );

      await reviewEmotionState.delete(review);

      verify(mockService.delete(review, reviewEmotion.position));
      expect(reviewEmotionState.isUpdated, false);
      expect(reviewEmotionState.status, ReviewEmotionStatus.deleted);
    });

    test('error message on bad info', () async {
      SharedPreferences.setMockInitialValues({});
      final reviewEmotion = testReviewEmotion();
      final mockService = MockReviewEmotionService();
      final reviewEmotionState =
          ReviewEmotionState(mockService, reviewEmotion: reviewEmotion);

      expect(reviewEmotionState.isCreate, false);
      expect(reviewEmotionState.isUpdated, false);

      final review = testReview();
      when(mockService.delete(review, reviewEmotion.position))
          .thenThrow(testApiError(400, "Cannot be empty."));

      await reviewEmotionState.delete(review);

      verify(mockService.delete(review, reviewEmotion.position));
      expect(reviewEmotionState.isUpdated, false);
      expect(reviewEmotionState.error, "Bad Request: Cannot be empty.");
    });

    test('error message on unauthorised info', () async {
      SharedPreferences.setMockInitialValues({});
      final reviewEmotion = testReviewEmotion();
      final mockService = MockReviewEmotionService();
      final reviewEmotionState = ReviewEmotionState(
        mockService,
        reviewEmotion: reviewEmotion,
      );

      expect(reviewEmotionState.isCreate, false);
      expect(reviewEmotionState.isUpdated, false);

      final review = testReview();
      when(mockService.delete(review, reviewEmotion.position))
          .thenThrow(testApiError(401, "User not logged in."));

      await reviewEmotionState.delete(review);

      verify(mockService.delete(review, reviewEmotion.position));
      expect(reviewEmotionState.isUpdated, false);
      expect(reviewEmotionState.error, "Unauthorised: User not logged in.");
    });
  });
  group("update", () {
    test('After update in isUpdated', () async {
      SharedPreferences.setMockInitialValues({});
      final reviewEmotion = testReviewEmotion();
      final reviewEmotionResp = ReviewEmotionResp(reviewEmotion: reviewEmotion);

      final mockService = MockReviewEmotionService();

      final reviewEmotionState =
          ReviewEmotionState(mockService, reviewEmotion: reviewEmotion);

      expect(reviewEmotionState.isCreate, false);
      expect(reviewEmotionState.isUpdated, false);

      final review = testReview();
      when(mockService.update(review, reviewEmotion.position, reviewEmotion))
          .thenAnswer((realInvocation) async => reviewEmotionResp);

      await reviewEmotionState.update(review);

      verify(mockService.update(review, reviewEmotion.position, reviewEmotion));
      expect(reviewEmotionState.isUpdated, true);
    });

    test('error message on bad info', () async {
      SharedPreferences.setMockInitialValues({});
      final mockService = MockReviewEmotionService();
      final reviewEmotion = testReviewEmotion();
      final reviewEmotionState = ReviewEmotionState(
        mockService,
        reviewEmotion: reviewEmotion,
      );

      expect(reviewEmotionState.isCreate, false);
      expect(reviewEmotionState.isUpdated, false);

      final review = testReview();
      when(mockService.update(review, reviewEmotion.position, reviewEmotion))
          .thenThrow(testApiError(400, "Cannot be empty."));

      await reviewEmotionState.update(review);

      verify(mockService.update(review, reviewEmotion.position, reviewEmotion));
      expect(reviewEmotionState.isUpdated, false);
      expect(reviewEmotionState.error, "Bad Request: Cannot be empty.");
    });

    test('error message on unauthorised info', () async {
      SharedPreferences.setMockInitialValues({});
      final mockService = MockReviewEmotionService();
      final reviewEmotion = testReviewEmotion();
      final reviewEmotionState = ReviewEmotionState(
        mockService,
        reviewEmotion: reviewEmotion,
      );

      expect(reviewEmotionState.isCreate, false);
      expect(reviewEmotionState.isUpdated, false);

      final review = testReview();
      when(mockService.update(review, reviewEmotion.position, reviewEmotion))
          .thenThrow(testApiError(401, "User not logged in."));

      await reviewEmotionState.update(review);

      verify(mockService.update(review, reviewEmotion.position, reviewEmotion));
      expect(reviewEmotionState.isUpdated, false);
      expect(reviewEmotionState.error, "Unauthorised: User not logged in.");
    });
  });

  group("get", () {
    test('After get is there', () async {
      SharedPreferences.setMockInitialValues({});
      final reviewEmotion = testReviewEmotion();

      final mockService = MockReviewEmotionService();
      final reviewEmotionState = ReviewEmotionState(
        mockService,
        reviewEmotion: reviewEmotion,
      );

      expect(reviewEmotionState.isCreate, false);
      expect(reviewEmotionState.isUpdated, false);
    });
  });
}
