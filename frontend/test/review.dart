import 'package:flutter_test/flutter_test.dart';

import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storystains/models/review.dart';
import 'package:storystains/modules/review/review.dart';

import 'review.mocks.dart';

@GenerateMocks([ReviewService])
void main() async {
  group('basic review', () {
    test('starts open', () async {
      final reviewService = ReviewService();
      final reviewState = ReviewState(reviewService);

      expect(reviewState.isOpen, false);
    });

    test('put', () async {
      SharedPreferences.setMockInitialValues({});
      final mockReviewService = MockReviewService();
      final reviewState = ReviewState(mockReviewService);
      final review = Review(
          slug: "s",
          title: "t",
          review: "r",
          createdAt: DateTime.now(),
          modifiedAt: DateTime.now());
      final editReview = EditReview(
        title: "t",
        review: "r",
      );
      when(mockReviewService.update(editReview))
          .thenAnswer((_) async => review);
      await reviewState.update(editReview);

      expect(reviewState.isChanged, true);
    });

    test('post', () async {
      SharedPreferences.setMockInitialValues({});
      final mockReviewService = MockReviewService();
      final reviewState = ReviewState(mockReviewService);
      final review = Review(
          slug: "s",
          title: "t",
          review: "r",
          createdAt: DateTime.now(),
          modifiedAt: DateTime.now());
      final editReview = EditReview(
        title: "t",
        review: "r",
      );
      when(mockReviewService.add(editReview)).thenAnswer((_) async => review);
      await reviewState.add(editReview);

      expect(reviewState.isChanged, true);
    });
  });
}
