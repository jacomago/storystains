
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storystains/common/constant/app_config.dart';
import 'package:storystains/features/reviews/reviews_service.dart';
import 'package:storystains/features/reviews/reviews_state.dart';
import 'package:storystains/model/entity/review.dart';
import 'package:mockito/annotations.dart';
import 'package:storystains/model/resp/reviews_resp.dart';

import 'reviews_test.mocks.dart';

@GenerateMocks([ReviewsService])
void main() {
  setUp(() => {WidgetsFlutterBinding.ensureInitialized()});
  group("get", () {
    test('init test', () async {
      SharedPreferences.setMockInitialValues({});
      const title = "title";
      const body = "body";
      final review = Review(
          title: title,
          body: body,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          slug: title);
      final reviewsResp = ReviewsResp(reviews: [review]);

      final mockService = MockReviewsService();
      when(mockService.fetch('', 0))
          .thenAnswer((realInvocation) async => reviewsResp.reviews);

      final reviewState = ReviewsState(mockService);

      verify(mockService.fetch('', 0));
      expect(reviewState.isLoadingMore, false);
      expect(reviewState.isEmpty, false);
    });
    test('fetch test', () async {
      SharedPreferences.setMockInitialValues({});
      const title = "title";
      const body = "body";
      final review = Review(
          title: title,
          body: body,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          slug: title);
      final reviewsResp = ReviewsResp(reviews: List.filled(45, review));

      final mockService = MockReviewsService();
      when(mockService.fetch('', 0)).thenAnswer((realInvocation) async =>
          reviewsResp.reviews.sublist(0, AppConfig.defaultLimit));
      when(mockService.fetch('', 2 * AppConfig.defaultLimit)).thenAnswer(
          (realInvocation) async => reviewsResp.reviews
              .sublist(AppConfig.defaultLimit, 2 * AppConfig.defaultLimit));

      final reviewState = ReviewsState(mockService);

      verify(mockService.fetch('', 0));
      expect(reviewState.isLoadingMore, false);
      expect(reviewState.isEmpty, false);

      await reviewState.fetch();

      expect(reviewState.isLoadingMore, false);
      expect(reviewState.isEmpty, false);
      expect(reviewState.count, AppConfig.defaultLimit);
    });
    test('fetch twice test', () async {
      SharedPreferences.setMockInitialValues({});
      const title = "title";
      const body = "body";
      final review = Review(
          title: title,
          body: body,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          slug: title);
      final reviewsResp = ReviewsResp(reviews: List.filled(45, review));

      final mockService = MockReviewsService();
      when(mockService.fetch('', 0)).thenAnswer((realInvocation) async =>
          reviewsResp.reviews.sublist(0, AppConfig.defaultLimit));
      when(mockService.fetch('', 2 * AppConfig.defaultLimit)).thenAnswer(
          (realInvocation) async => reviewsResp.reviews
              .sublist(AppConfig.defaultLimit, 2 * AppConfig.defaultLimit));

      final reviewState = ReviewsState(mockService);

      verify(mockService.fetch('', 0));
      expect(reviewState.isLoadingMore, false);
      expect(reviewState.isEmpty, false);

      await reviewState.fetch();
      await reviewState.fetch();

      verify(mockService.fetch('', 2 * AppConfig.defaultLimit));
      expect(reviewState.isLoadingMore, false);
      expect(reviewState.isEmpty, false);
      expect(reviewState.count, 2 * AppConfig.defaultLimit);
    });
    test('refresh test', () async {
      SharedPreferences.setMockInitialValues({});
      const title = "title";
      const body = "body";
      final review = Review(
          title: title,
          body: body,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          slug: title);
      final reviewsResp = ReviewsResp(reviews: List.filled(45, review));

      final mockService = MockReviewsService();
      when(mockService.fetch('', 0)).thenAnswer((realInvocation) async =>
          reviewsResp.reviews.sublist(0, AppConfig.defaultLimit));
      when(mockService.fetch('', 2 * AppConfig.defaultLimit)).thenAnswer(
          (realInvocation) async => reviewsResp.reviews
              .sublist(AppConfig.defaultLimit, 2 * AppConfig.defaultLimit));
      when(mockService.fetch('', 0)).thenAnswer((realInvocation) async =>
          reviewsResp.reviews.sublist(0, AppConfig.defaultLimit));

      final reviewState = ReviewsState(mockService);

      verify(mockService.fetch('', 0));
      expect(reviewState.isLoadingMore, false);
      expect(reviewState.isEmpty, false);

      await reviewState.fetch();
      await reviewState.fetch();

      expect(reviewState.isLoadingMore, false);
      expect(reviewState.isEmpty, false);
      expect(reviewState.count, 2 * AppConfig.defaultLimit);

      await reviewState.refresh();
      verify(mockService.fetch('', 0));
      expect(reviewState.isLoadingMore, false);
      expect(reviewState.isEmpty, false);
    });
  });
}

// TODO Test Get all reviews
// TODO Test handle get reviews error
// TODO Test handle get reviews no data