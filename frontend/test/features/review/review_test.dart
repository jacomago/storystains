import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storystains/features/review/review_service.dart';
import 'package:storystains/features/review/review_state.dart';
import 'package:storystains/model/entity/review.dart';
import 'package:storystains/model/entity/user.dart';
import 'package:storystains/model/resp/review_resp.dart';
import 'package:mockito/annotations.dart';

import 'review_test.mocks.dart';

@GenerateMocks([ReviewService])
void main() {
  setUp(() => {WidgetsFlutterBinding.ensureInitialized()});
  group("create", () {
    test('After create in isUpdated', () async {
      SharedPreferences.setMockInitialValues({});
      const title = "title";
      const body = "body";
      final review = Review(
        title: title,
        body: body,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        slug: title,
        emotions: [],
        user: UserProfile(username: "username"),
      );
      final reviewResp = ReviewResp(review: review);

      final mockService = MockReviewService();
      final reviewState = ReviewState(mockService);

      expect(reviewState.isCreate, true);

      when(mockService.create(title, body))
          .thenAnswer((realInvocation) async => reviewResp);

      await reviewState.update(title, body);

      verify(mockService.create(title, body));
      expect(reviewState.isUpdated, true);
    });

    test('error message on bad info', () async {
      SharedPreferences.setMockInitialValues({});
      final mockService = MockReviewService();
      final reviewState = ReviewState(mockService);

      expect(reviewState.isCreate, true);

      when(mockService.create("", "")).thenThrow(DioError(
        requestOptions: RequestOptions(path: ""),
        type: DioErrorType.response,
        response: Response(
          statusCode: 400,
          data: "Cannot be empty.",
          requestOptions: RequestOptions(path: ""),
        ),
      ));

      await reviewState.update("", "");

      verify(mockService.create("", ""));
      expect(reviewState.isUpdated, false);
      expect(reviewState.error, "Bad Request: Cannot be empty.");
    });

    test('error message on unauthorised info', () async {
      SharedPreferences.setMockInitialValues({});
      final mockService = MockReviewService();
      final reviewState = ReviewState(mockService);

      expect(reviewState.isCreate, true);

      when(mockService.create("", "")).thenThrow(DioError(
        requestOptions: RequestOptions(path: ""),
        type: DioErrorType.response,
        response: Response(
          statusCode: 401,
          data: "User not logged in.",
          requestOptions: RequestOptions(path: ""),
        ),
      ));

      await reviewState.update("", "");

      verify(mockService.create("", ""));
      expect(reviewState.isUpdated, false);
      expect(reviewState.error, "Unauthorised: User not logged in.");
    });
  });
  group("delete", () {
    test('After delete in initial', () async {
      SharedPreferences.setMockInitialValues({});
      const title = "title";
      const body = "body";
      final review = Review(
        title: title,
        body: body,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        slug: title,
        emotions: [],
        user: UserProfile(username: "username"),
      );

      final mockService = MockReviewService();

      final reviewState = ReviewState(mockService, review);

      expect(reviewState.isCreate, false);
      expect(reviewState.isUpdated, false);

      when(mockService.delete(title)).thenAnswer((realInvocation) async =>
          Response(requestOptions: RequestOptions(path: ""), statusCode: 200));

      await reviewState.delete(title);

      verify(mockService.delete(title));
      expect(reviewState.isUpdated, false);
      expect(reviewState.status, ReviewStatus.initial);
    });

    test('error message on bad info', () async {
      SharedPreferences.setMockInitialValues({});
      final mockService = MockReviewService();
      final reviewState = ReviewState(
        mockService,
        Review(
          title: "",
          body: "",
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          slug: "",
          emotions: [],
          user: UserProfile(username: "username"),
        ),
      );

      expect(reviewState.isCreate, false);
      expect(reviewState.isUpdated, false);

      when(mockService.delete("")).thenThrow(DioError(
        requestOptions: RequestOptions(path: ""),
        type: DioErrorType.response,
        response: Response(
          statusCode: 400,
          data: "Cannot be empty.",
          requestOptions: RequestOptions(path: ""),
        ),
      ));

      await reviewState.delete("");

      verify(mockService.delete(""));
      expect(reviewState.isUpdated, false);
      expect(reviewState.error, "Bad Request: Cannot be empty.");
    });

    test('error message on unauthorised info', () async {
      SharedPreferences.setMockInitialValues({});
      final mockService = MockReviewService();
      final reviewState = ReviewState(
        mockService,
        Review(
          title: "",
          body: "",
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          slug: "",
          emotions: [],
          user: UserProfile(username: "username"),
        ),
      );

      expect(reviewState.isCreate, false);
      expect(reviewState.isUpdated, false);

      when(mockService.delete("")).thenThrow(DioError(
        requestOptions: RequestOptions(path: ""),
        type: DioErrorType.response,
        response: Response(
          statusCode: 401,
          data: "User not logged in.",
          requestOptions: RequestOptions(path: ""),
        ),
      ));

      await reviewState.delete("");

      verify(mockService.delete(""));
      expect(reviewState.isUpdated, false);
      expect(reviewState.error, "Unauthorised: User not logged in.");
    });
  });
  group("update", () {
    test('After update in isUpdated', () async {
      SharedPreferences.setMockInitialValues({});
      const title = "title";
      const body = "body";
      final review = Review(
        title: title,
        body: body,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        slug: title,
        emotions: [],
        user: UserProfile(username: "username"),
      );
      final reviewResp = ReviewResp(review: review);

      final mockService = MockReviewService();

      final reviewState = ReviewState(mockService, review);

      expect(reviewState.isCreate, false);
      expect(reviewState.isUpdated, false);

      when(mockService.update(title, title, body))
          .thenAnswer((realInvocation) async => reviewResp);

      await reviewState.update(title, body);

      verify(mockService.update(title, title, body));
      expect(reviewState.isUpdated, true);
    });

    test('error message on bad info', () async {
      SharedPreferences.setMockInitialValues({});
      final mockService = MockReviewService();
      final reviewState = ReviewState(
        mockService,
        Review(
          title: "",
          body: "",
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          slug: "",
          emotions: [],
          user: UserProfile(username: "username"),
        ),
      );

      expect(reviewState.isCreate, false);
      expect(reviewState.isUpdated, false);

      when(mockService.update("", "", "")).thenThrow(DioError(
        requestOptions: RequestOptions(path: ""),
        type: DioErrorType.response,
        response: Response(
          statusCode: 400,
          data: "Cannot be empty.",
          requestOptions: RequestOptions(path: ""),
        ),
      ));

      await reviewState.update("", "");

      verify(mockService.update("", "", ""));
      expect(reviewState.isUpdated, false);
      expect(reviewState.error, "Bad Request: Cannot be empty.");
    });

    test('error message on unauthorised info', () async {
      SharedPreferences.setMockInitialValues({});
      final mockService = MockReviewService();
      final reviewState = ReviewState(
        mockService,
        Review(
          title: "",
          body: "",
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          slug: "",
          emotions: [],
          user: UserProfile(username: "username"),
        ),
      );

      expect(reviewState.isCreate, false);
      expect(reviewState.isUpdated, false);

      when(mockService.update("", "", "")).thenThrow(DioError(
        requestOptions: RequestOptions(path: ""),
        type: DioErrorType.response,
        response: Response(
          statusCode: 401,
          data: "User not logged in.",
          requestOptions: RequestOptions(path: ""),
        ),
      ));

      await reviewState.update("", "");

      verify(mockService.update("", "", ""));
      expect(reviewState.isUpdated, false);
      expect(reviewState.error, "Unauthorised: User not logged in.");
    });
  });

  group("get", () {
    test('After get is there', () async {
      SharedPreferences.setMockInitialValues({});
      const title = "title";
      const body = "body";
      final review = Review(
        title: title,
        body: body,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        slug: title,
        emotions: [],
        user: UserProfile(username: "username"),
      );

      final mockService = MockReviewService();
      final reviewState = ReviewState(mockService, review);

      expect(reviewState.isCreate, false);
      expect(reviewState.isUpdated, false);
    });
  });
}