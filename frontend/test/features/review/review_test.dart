import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storystains/features/mediums/medium.dart';
import 'package:storystains/features/review/review.dart';
import 'package:mockito/annotations.dart';
import 'package:storystains/features/story/story.dart';

import '../../common/errors.dart';
import 'review.dart';
import 'review_test.mocks.dart';

@GenerateMocks([ReviewService])
void main() {
  setUp(() => {WidgetsFlutterBinding.ensureInitialized()});
  group("create", () {
    test('After create in isUpdated', () async {
      SharedPreferences.setMockInitialValues({});
      final review = testReview();
      final reviewResp = ReviewResp(review: review);

      final mockService = MockReviewService();
      final reviewState = ReviewState(mockService);

      expect(reviewState.isCreate, true);

      when(mockService.create(review.story, review.body))
          .thenAnswer((realInvocation) async => reviewResp);

      await reviewState.update(review.story, review.body);

      verify(mockService.create(review.story, review.body));
      expect(reviewState.isUpdated, true);
    });

    test('error message on bad info', () async {
      SharedPreferences.setMockInitialValues({});
      final mockService = MockReviewService();
      final reviewState = ReviewState(mockService);

      expect(reviewState.isCreate, true);

      when(mockService.create(
        Story(
          title: "",
          medium: Medium.mediumDefault,
          creator: "",
        ),
        "",
      )).thenThrow(testApiError(400, "Cannot be empty."));

      await reviewState.update(
        Story(
          title: "",
          medium: Medium.mediumDefault,
          creator: "",
        ),
        "",
      );

      verify(mockService.create(
        Story(
          title: "",
          medium: Medium.mediumDefault,
          creator: "",
        ),
        "",
      ));
      expect(reviewState.isUpdated, false);
      expect(reviewState.error, "Bad Request: Cannot be empty.");
    });

    test('error message on unauthorised info', () async {
      SharedPreferences.setMockInitialValues({});
      final mockService = MockReviewService();
      final reviewState = ReviewState(mockService);

      expect(reviewState.isCreate, true);

      when(mockService.create(
        Story(
          title: "",
          medium: Medium(name: ""),
          creator: "",
        ),
        "",
      )).thenThrow(testApiError(401, "User not logged in."));

      await reviewState.update(
        Story(
          title: "",
          medium: Medium(name: ""),
          creator: "",
        ),
        "",
      );

      verify(mockService.create(
        Story(
          title: "",
          medium: Medium(name: ""),
          creator: "",
        ),
        "",
      ));
      expect(reviewState.isUpdated, false);
      expect(reviewState.error, "Unauthorised: User not logged in.");
    });
  });
  group("delete", () {
    test('After delete in initial', () async {
      SharedPreferences.setMockInitialValues({});
      final review = testReview();

      final mockService = MockReviewService();

      final reviewState = ReviewState(mockService, review: review);

      expect(reviewState.isCreate, false);
      expect(reviewState.isUpdated, false);

      when(mockService.delete(review.user.username, review.slug)).thenAnswer(
        (realInvocation) async => Response<dynamic>(
            requestOptions: RequestOptions(path: ""), statusCode: 200),
      );

      await reviewState.delete();

      verify(mockService.delete(review.user.username, review.slug));
      expect(reviewState.isUpdated, false);
      expect(reviewState.status, ReviewStatus.deleted);
    });

    test('error message on bad info', () async {
      SharedPreferences.setMockInitialValues({});
      final review = testReview(slug: "");
      final mockService = MockReviewService();
      final reviewState = ReviewState(mockService, review: review);

      expect(reviewState.isCreate, false);
      expect(reviewState.isUpdated, false);

      when(mockService.delete(review.user.username, ""))
          .thenThrow(testApiError(400, "Cannot be empty."));

      await reviewState.delete();

      verify(mockService.delete(review.user.username, ""));
      expect(reviewState.isUpdated, false);
      expect(reviewState.error, "Bad Request: Cannot be empty.");
    });

    test('error message on unauthorised info', () async {
      SharedPreferences.setMockInitialValues({});
      final review = testReview();
      final mockService = MockReviewService();
      final reviewState = ReviewState(
        mockService,
        review: review,
      );

      expect(reviewState.isCreate, false);
      expect(reviewState.isUpdated, false);

      when(mockService.delete(review.user.username, review.slug))
          .thenThrow(DioError(
        requestOptions: RequestOptions(path: ""),
        type: DioErrorType.response,
        response: Response(
          statusCode: 401,
          data: "User not logged in.",
          requestOptions: RequestOptions(path: ""),
        ),
      ));

      await reviewState.delete();

      verify(mockService.delete(review.user.username, review.slug));
      expect(reviewState.isUpdated, false);
      expect(reviewState.error, "Unauthorised: User not logged in.");
    });
  });
  group("update", () {
    test('After update in isUpdated', () async {
      SharedPreferences.setMockInitialValues({});
      final review = testReview();
      final reviewResp = ReviewResp(review: review);

      final mockService = MockReviewService();

      final reviewState = ReviewState(mockService, review: review);

      expect(reviewState.isCreate, false);
      expect(reviewState.isUpdated, false);

      when(mockService.update(
        review.user.username,
        review.slug,
        review.story,
        review.body,
      )).thenAnswer((realInvocation) async => reviewResp);

      await reviewState.update(review.story, review.body);

      verify(mockService.update(
        review.user.username,
        review.slug,
        review.story,
        review.body,
      ));
      expect(reviewState.isUpdated, true);
    });

    test('error message on bad info', () async {
      SharedPreferences.setMockInitialValues({});
      final mockService = MockReviewService();
      final review = testReview(
        slug: "",
      );
      final reviewState = ReviewState(
        mockService,
        review: review,
      );

      expect(reviewState.isCreate, false);
      expect(reviewState.isUpdated, false);

      when(mockService.update(
        review.user.username,
        "",
        Story(
          title: "",
          medium: Medium(name: ""),
          creator: "",
        ),
        "",
      )).thenThrow(testApiError(400, "Cannot be empty."));

      await reviewState.update(
        Story(
          title: "",
          medium: Medium(name: ""),
          creator: "",
        ),
        "",
      );

      verify(mockService.update(
        review.user.username,
        "",
        Story(
          title: "",
          medium: Medium(name: ""),
          creator: "",
        ),
        "",
      ));
      expect(reviewState.isUpdated, false);
      expect(reviewState.error, "Bad Request: Cannot be empty.");
    });

    test('error message on unauthorised info', () async {
      SharedPreferences.setMockInitialValues({});
      final mockService = MockReviewService();
      final review = testReview(
        slug: "",
      );
      final reviewState = ReviewState(
        mockService,
        review: review,
      );

      expect(reviewState.isCreate, false);
      expect(reviewState.isUpdated, false);

      when(mockService.update(
        review.user.username,
        "",
        Story(
          title: "",
          medium: Medium(name: ""),
          creator: "",
        ),
        "",
      )).thenThrow(testApiError(401, "User not logged in."));

      await reviewState.update(
        Story(
          title: "",
          medium: Medium(name: ""),
          creator: "",
        ),
        "",
      );

      verify(mockService.update(
        review.user.username,
        "",
        Story(
          title: "",
          medium: Medium(name: ""),
          creator: "",
        ),
        "",
      ));
      expect(reviewState.isUpdated, false);
      expect(reviewState.error, "Unauthorised: User not logged in.");
    });
  });

  group("get", () {
    test('After get is there', () async {
      SharedPreferences.setMockInitialValues({});
      final review = testReview();

      final mockService = MockReviewService();
      final reviewState = ReviewState(mockService, review: review);

      expect(reviewState.isCreate, false);
      expect(reviewState.isUpdated, false);
    });
    test('error on get', () async {
      SharedPreferences.setMockInitialValues({});
      final review = testReview();

      final mockService = MockReviewService();

      when(mockService.read(review.user.username, review.slug))
          .thenThrow(testApiError(401, "Some error."));

      final reviewState = ReviewState(
        mockService,
        path: ReviewRoutePath(
          review.slug,
          review.user.username,
        ),
      );

      expect(reviewState.isCreate, false);
      expect(reviewState.isUpdated, false);
      expect(reviewState.error, "Unauthorised: Some error.");
    });
    test('init works', () async {
      SharedPreferences.setMockInitialValues({});
      final review = testReview();

      final mockService = MockReviewService();

      when(mockService.read(review.user.username, review.slug))
          .thenAnswer((realInvocation) async => ReviewResp(review: review));

      final reviewState = ReviewState(
        mockService,
        path: ReviewRoutePath(
          review.slug,
          review.user.username,
        ),
      );

      await Future<void>.delayed(const Duration(seconds: 1));
      expect(reviewState.isCreate, false);
      expect(reviewState.isUpdated, false);
      expect(reviewState.status, ReviewStatus.read);
      expect(reviewState.review, review);
    });
  });
}
