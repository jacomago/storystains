import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storystains/features/review/review_service.dart';
import 'package:storystains/features/review/review_state.dart';
import 'package:storystains/model/entity/review.dart';
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
          slug: title);
      final reviewResp = ReviewResp(review: review);

      final mockService = MockReviewService();
      final reviewState = ReviewState(mockService);

      expect(reviewState.isCreate, true);

      when(mockService.create(title, body))
          .thenAnswer((realInvocation) async => reviewResp);

      await reviewState.create(title, body);

      verify(mockService.create(title, body));
      expect(reviewState.isUpdated, true);
    });

    test('error message on bad info', () async {
      SharedPreferences.setMockInitialValues({});
      final mockService = MockReviewService();
      final reviewState = ReviewState(mockService);

      expect(reviewState.isCreate, true);

      when(mockService.create("", "")).thenAnswer((realInvocation) async =>
          Response(requestOptions: RequestOptions(path: ""), statusCode: 401));

      await reviewState.create("", "");

      verify(mockService.create("", ""));
      expect(reviewState.isUpdated, false);
    });
  });
}

// TODO Test Get all reviews
// TODO Test handle get reviews error
// TODO Test handle get reviews no data
// TODO Test Get a review
// TODO Test handle get review error
// TODO Test create review
// TODO Test create review error
// TODO Test edit review
// TODO Test edit review error