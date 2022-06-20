import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storystains/common/constant/app_config.dart';
import 'package:storystains/features/reviews/reviews_service.dart';
import 'package:storystains/features/reviews/reviews_state.dart';
import 'package:storystains/model/entity/review.dart';
import 'package:mockito/annotations.dart';
import 'package:storystains/model/entity/user.dart';
import 'package:storystains/model/resp/reviews_resp.dart';

import '../../model/review.dart';
import 'reviews_test.mocks.dart';

@GenerateMocks([ReviewsService])
void main() {
  setUp(() => {WidgetsFlutterBinding.ensureInitialized()});
  group("get", () {
    test('init test', () async {
      SharedPreferences.setMockInitialValues({});
      final review = testReview(slug: "randomtitle");
      final reviewsResp = ReviewsResp(reviews: [review]);

      final mockService = MockReviewsService();
      when(mockService.fetch())
          .thenAnswer((realInvocation) async => reviewsResp.reviews);

      final reviewState = ReviewsState(mockService);

      verify(mockService.fetch());
      expect(reviewState.isLoadingMore, false);
      expect(reviewState.isEmpty, false);
    });
    test('init null test', () async {
      SharedPreferences.setMockInitialValues({});

      final mockService = MockReviewsService();
      when(mockService.fetch()).thenAnswer((realInvocation) async => null);

      final reviewState = ReviewsState(mockService);

      verify(mockService.fetch());
      expect(reviewState.isLoadingMore, false);
      expect(reviewState.isEmpty, false);
    });
    test('fetch test', () async {
      SharedPreferences.setMockInitialValues({});
      final review = testReview(slug: "randomtitle");
      final reviewsResp = ReviewsResp(reviews: List.filled(45, review));

      final mockService = MockReviewsService();
      when(mockService.fetch()).thenAnswer((realInvocation) async =>
          reviewsResp.reviews.sublist(0, AppConfig.defaultLimit));
      when(mockService.fetch(offset: 2 * AppConfig.defaultLimit)).thenAnswer(
        (realInvocation) async => reviewsResp.reviews
            .sublist(AppConfig.defaultLimit, 2 * AppConfig.defaultLimit),
      );

      final reviewState = ReviewsState(mockService);

      verify(mockService.fetch());
      expect(reviewState.isLoadingMore, false);
      expect(reviewState.isEmpty, false);

      await reviewState.fetch();

      expect(reviewState.isLoadingMore, false);
      expect(reviewState.isEmpty, false);
      expect(reviewState.count, AppConfig.defaultLimit);
    });
    test('fetch twice test', () async {
      SharedPreferences.setMockInitialValues({});
      final reviewsResp = ReviewsResp(
        reviews: List.generate(
          45,
          (int index) => testReview(slug: "title$index"),
        ),
      );

      final mockService = MockReviewsService();
      when(mockService.fetch()).thenAnswer((realInvocation) async =>
          reviewsResp.reviews.sublist(0, AppConfig.defaultLimit));
      when(mockService.fetch(query: '', offset: AppConfig.defaultLimit))
          .thenAnswer((realInvocation) async => reviewsResp.reviews
              .sublist(AppConfig.defaultLimit, 2 * AppConfig.defaultLimit));

      final reviewState = ReviewsState(mockService);

      verify(mockService.fetch());
      expect(reviewState.isLoadingMore, false);
      expect(reviewState.isEmpty, false);

      await reviewState.fetch();
      await reviewState.fetch();

      verify(mockService.fetch(offset: AppConfig.defaultLimit));
      expect(reviewState.isLoadingMore, false);
      expect(reviewState.isEmpty, false);
      expect(reviewState.count, 2 * AppConfig.defaultLimit);
    });

    test('fetch null test', () async {
      SharedPreferences.setMockInitialValues({});

      final mockService = MockReviewsService();
      when(mockService.fetch()).thenAnswer((realInvocation) async => null);

      final reviewState = ReviewsState(mockService);

      verify(mockService.fetch());
      expect(reviewState.isLoadingMore, false);
      expect(reviewState.isEmpty, false);
      await reviewState.fetch();

      expect(reviewState.isLoadingMore, false);
      expect(reviewState.isEmpty, false);
      expect(reviewState.isFailed, true);
    });

    test('fetch empty test', () async {
      SharedPreferences.setMockInitialValues({});

      final mockService = MockReviewsService();
      when(mockService.fetch()).thenAnswer((realInvocation) async => []);

      final reviewState = ReviewsState(mockService);

      verify(mockService.fetch());
      expect(reviewState.isLoadingMore, false);
      expect(reviewState.isEmpty, false);
      await reviewState.fetch();

      expect(reviewState.isLoadingMore, false);
      expect(reviewState.isFailed, false);
      expect(reviewState.isEmpty, true);
    });

    test('refresh test', () async {
      SharedPreferences.setMockInitialValues({});
      final review = testReview(slug: "randomtitle");
      final reviewsResp = ReviewsResp(reviews: List.filled(45, review));

      final mockService = MockReviewsService();
      when(mockService.fetch()).thenAnswer((realInvocation) async =>
          reviewsResp.reviews.sublist(0, AppConfig.defaultLimit));
      when(mockService.fetch(offset: AppConfig.defaultLimit)).thenAnswer(
        (realInvocation) async => reviewsResp.reviews
            .sublist(AppConfig.defaultLimit, 2 * AppConfig.defaultLimit),
      );
      when(mockService.fetch()).thenAnswer((realInvocation) async =>
          reviewsResp.reviews.sublist(0, AppConfig.defaultLimit));

      final reviewState = ReviewsState(mockService);

      verify(mockService.fetch());
      expect(reviewState.isLoadingMore, false);
      expect(reviewState.isEmpty, false);

      await reviewState.fetch();
      await reviewState.fetch();

      expect(reviewState.isLoadingMore, false);
      expect(reviewState.isEmpty, false);
      expect(reviewState.count, 2 * AppConfig.defaultLimit);

      await reviewState.refresh();
      verify(mockService.fetch());
      expect(reviewState.isLoadingMore, false);
      expect(reviewState.isEmpty, false);
    });
  });
}
