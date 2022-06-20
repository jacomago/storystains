import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mockito/annotations.dart';
import 'package:storystains/features/review_emotion/review_emotion.dart';
import 'package:storystains/model/entity/review_emotion.dart';
import 'package:storystains/model/resp/review_emotion_resp.dart';

import '../../model/review_emotion.dart';
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

      const slug = "slug";
      when(mockService.create(slug, reviewEmotion))
          .thenAnswer((realInvocation) async => reviewEmotionResp);

      updateControllers(reviewEmotionState, reviewEmotion);
      await reviewEmotionState.update(slug);

      verify(mockService.create(slug, reviewEmotion));
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

      when(mockService.create(
        "",
        reviewEmotion,
      )).thenThrow(DioError(
        requestOptions: RequestOptions(path: ""),
        type: DioErrorType.response,
        response: Response(
          statusCode: 400,
          data: "Cannot be empty.",
          requestOptions: RequestOptions(path: ""),
        ),
      ));

      updateControllers(reviewEmotionState, reviewEmotion);
      await reviewEmotionState.update("");

      verify(mockService.create("", testReviewEmotion()));
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

      when(mockService.create(
        "",
        reviewEmotion,
      )).thenThrow(DioError(
        requestOptions: RequestOptions(path: ""),
        type: DioErrorType.response,
        response: Response(
          statusCode: 401,
          data: "User not logged in.",
          requestOptions: RequestOptions(path: ""),
        ),
      ));

      updateControllers(reviewEmotionState, reviewEmotion);
      await reviewEmotionState.update(
        "",
      );

      verify(mockService.create("", reviewEmotion));
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

      const slug = "slug";
      when(mockService.delete(slug, reviewEmotion.position)).thenAnswer(
        (realInvocation) async =>
            Response(requestOptions: RequestOptions(path: ""), statusCode: 200),
      );

      await reviewEmotionState.delete(slug, reviewEmotion.position);

      verify(mockService.delete(slug, reviewEmotion.position));
      expect(reviewEmotionState.isUpdated, false);
      expect(reviewEmotionState.status, ReviewEmotionStatus.initial);
    });

    test('error message on bad info', () async {
      SharedPreferences.setMockInitialValues({});
      final reviewEmotion = testReviewEmotion();
      final mockService = MockReviewEmotionService();
      final reviewEmotionState =
          ReviewEmotionState(mockService, reviewEmotion: reviewEmotion);

      expect(reviewEmotionState.isCreate, false);
      expect(reviewEmotionState.isUpdated, false);

      const slug = "slug";
      when(mockService.delete(slug, reviewEmotion.position)).thenThrow(DioError(
        requestOptions: RequestOptions(path: ""),
        type: DioErrorType.response,
        response: Response(
          statusCode: 400,
          data: "Cannot be empty.",
          requestOptions: RequestOptions(path: ""),
        ),
      ));

      await reviewEmotionState.delete(slug, reviewEmotion.position);

      verify(mockService.delete(slug, reviewEmotion.position));
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

      const slug = "slug";
      when(mockService.delete(slug, reviewEmotion.position)).thenThrow(DioError(
        requestOptions: RequestOptions(path: ""),
        type: DioErrorType.response,
        response: Response(
          statusCode: 401,
          data: "User not logged in.",
          requestOptions: RequestOptions(path: ""),
        ),
      ));

      await reviewEmotionState.delete(slug, reviewEmotion.position);

      verify(mockService.delete(slug, reviewEmotion.position));
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

      const slug = "slug";
      when(mockService.update(slug, reviewEmotion.position, reviewEmotion))
          .thenAnswer((realInvocation) async => reviewEmotionResp);

      await reviewEmotionState.update(slug);

      verify(mockService.update(slug, reviewEmotion.position, reviewEmotion));
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

      const slug = "slug";
      when(mockService.update(slug, reviewEmotion.position, reviewEmotion))
          .thenThrow(DioError(
        requestOptions: RequestOptions(path: ""),
        type: DioErrorType.response,
        response: Response(
          statusCode: 400,
          data: "Cannot be empty.",
          requestOptions: RequestOptions(path: ""),
        ),
      ));

      await reviewEmotionState.update(slug);

      verify(mockService.update(slug, reviewEmotion.position, reviewEmotion));
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

      const slug = "slug";
      when(mockService.update(slug, reviewEmotion.position, reviewEmotion))
          .thenThrow(DioError(
        requestOptions: RequestOptions(path: ""),
        type: DioErrorType.response,
        response: Response(
          statusCode: 401,
          data: "User not logged in.",
          requestOptions: RequestOptions(path: ""),
        ),
      ));

      await reviewEmotionState.update(slug);

      verify(mockService.update(slug, reviewEmotion.position, reviewEmotion));
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
