import 'dart:math';

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
          Response(
              requestOptions: RequestOptions(path: ""),
              statusCode: 400,
              statusMessage: "Cannot be empty."));

      await reviewState.create("", "");

      verify(mockService.create("", ""));
      expect(reviewState.isUpdated, false);
      expect(reviewState.error, "Bad Request: Cannot be empty.");
    });

    test('error message on unauthorised info', () async {
      SharedPreferences.setMockInitialValues({});
      final mockService = MockReviewService();
      final reviewState = ReviewState(mockService);

      expect(reviewState.isCreate, true);

      when(mockService.create("", "")).thenAnswer((realInvocation) async =>
          Response(
              requestOptions: RequestOptions(path: ""),
              statusCode: 401,
              statusMessage: "User not logged in."));

      await reviewState.create("", "");

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
          slug: title);

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
              slug: ""));

      expect(reviewState.isCreate, false);
      expect(reviewState.isUpdated, false);

      when(mockService.delete("")).thenAnswer((realInvocation) async =>
          Response(
              requestOptions: RequestOptions(path: ""),
              statusCode: 400,
              statusMessage: "Cannot be empty."));

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
              slug: ""));

      expect(reviewState.isCreate, false);
      expect(reviewState.isUpdated, false);

      when(mockService.delete("")).thenAnswer((realInvocation) async =>
          Response(
              requestOptions: RequestOptions(path: ""),
              statusCode: 401,
              statusMessage: "User not logged in."));

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
          slug: title);
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
              slug: ""));

      expect(reviewState.isCreate, false);
      expect(reviewState.isUpdated, false);

      when(mockService.update("", "", "")).thenAnswer((realInvocation) async =>
          Response(
              requestOptions: RequestOptions(path: ""),
              statusCode: 400,
              statusMessage: "Cannot be empty."));

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
              slug: ""));

      expect(reviewState.isCreate, false);
      expect(reviewState.isUpdated, false);

      when(mockService.update("", "", "")).thenAnswer((realInvocation) async =>
          Response(
              requestOptions: RequestOptions(path: ""),
              statusCode: 401,
              statusMessage: "User not logged in."));

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
          slug: title);
      final reviewResp = ReviewResp(review: review);

      final mockService = MockReviewService();
      final reviewState = ReviewState(mockService, review);

      expect(reviewState.isCreate, false);
      expect(reviewState.isUpdated, false);
    });
  });
}

// TODO Test Get all reviews
// TODO Test handle get reviews error
// TODO Test handle get reviews no data