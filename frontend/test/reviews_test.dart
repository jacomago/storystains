import 'package:flutter_test/flutter_test.dart';

import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storystains/config/config.dart';
import 'package:storystains/models/review.dart';
import 'package:storystains/modules/reviews/reviews.dart';

class MockReviewsService extends Mock implements ReviewsService {
  @override
  Future<List<Review>?> fetch(int limit, int offset) async {
    return List.generate(
        default_limit,
        ((index) => Review(
            slug: index.toString(),
            title: "s",
            review: "review",
            createdAt: DateTime.now(),
            modifiedAt: DateTime.now())));
  }
}

void main() async {
  group('basic reviews', () {
    test('starts not logged in', () async {
      final reviewsService = ReviewsService();
      final reviewsState = ReviewsState(reviewsService);

      expect(reviewsState.count, 0);
    });

    test('reviews state fetch', () async {
      SharedPreferences.setMockInitialValues({});
      final mockReviewsService = MockReviewsService();
      final reviewsState = ReviewsState(mockReviewsService);

      await reviewsState.fetch();

      expect(reviewsState.count, default_limit);
    });

    test('reviews state refresh', () async {
      SharedPreferences.setMockInitialValues({});
      final mockReviewsService = MockReviewsService();
      final reviewsState = ReviewsState(mockReviewsService);

      await reviewsState.fetch();
      await reviewsState.refresh();

      expect(reviewsState.count, default_limit);
    });
  });
}
