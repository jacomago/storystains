import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storystains/features/auth/auth.dart';
import 'package:storystains/features/emotions/emotion.dart';
import 'package:storystains/features/review/review.dart';

import 'review.dart';
import 'review_edit_test.mocks.dart';

Widget wrapWithMaterial(Widget w, ReviewState reviewState) => MultiProvider(
      providers: [
        ChangeNotifierProvider<ReviewState>(
          create: (_) => reviewState,
        ),
        ChangeNotifierProvider<AuthState>(
          create: (_) => AuthState(AuthService()),
        ),
        ChangeNotifierProvider<EmotionsState>(
          create: (_) => EmotionsState(EmotionsService()),
        ),
      ],
      child: MaterialApp(
        home: w,
      ),
    );

@GenerateMocks([ReviewService])
void main() {
  setUp(() => {WidgetsFlutterBinding.ensureInitialized()});
  group("Edit Review", () {
    testWidgets('fields exist', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final review = testReview();

      final reviewState = ReviewState(ReviewService(), review: review);
      await tester
          .pumpWidget(wrapWithMaterial(const ReviewWidget(), reviewState));

      final titleField = find.bySemanticsLabel('Title');
      expect(titleField, findsOneWidget);
      expect(find.text(review.title), findsOneWidget);

      final bodyField = find.bySemanticsLabel('Body');
      expect(bodyField, findsOneWidget);
      expect(find.text(review.body), findsOneWidget);

      await tester.enterText(titleField, "title1");
      await tester.pumpAndSettle();
      expect(find.text('title1'), findsOneWidget);

      await tester.enterText(bodyField, "body1");
      await tester.pumpAndSettle();
      expect(find.text('body1'), findsOneWidget);
    });
    testWidgets('error message editing on bad info', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final mockService = MockReviewService();
      final review = testReview(slug: "/");
      final reviewState = ReviewState(mockService, review: review);
      await tester
          .pumpWidget(wrapWithMaterial(const ReviewWidget(), reviewState));
      await tester.pumpAndSettle();

      when(mockService.update(
        review.user.username,
        review.title,
        review.slug,
        review.body,
      )).thenThrow(DioError(
        requestOptions: RequestOptions(path: ""),
        type: DioErrorType.response,
        response: Response(
          statusCode: 400,
          data: "Cannot be /.",
          requestOptions: RequestOptions(path: ""),
        ),
      ));

      expect(find.byType(FloatingActionButton), findsOneWidget);
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(
        find.widgetWithText(SnackBar, "Bad Request: Cannot be /."),
        findsOneWidget,
      );
    });
    testWidgets('error message creating on bad info', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final mockService = MockReviewService();
      final reviewState = ReviewState(mockService);

      await tester
          .pumpWidget(wrapWithMaterial(const ReviewWidget(), reviewState));
      await tester.pumpAndSettle();

      final titleField = find.bySemanticsLabel('Title');
      await tester.enterText(titleField, "/");

      final bodyField = find.bySemanticsLabel('Body');
      await tester.enterText(bodyField, "body");
      await tester.pumpAndSettle();

      when(mockService.create("/", "body")).thenThrow(DioError(
        requestOptions: RequestOptions(path: ""),
        type: DioErrorType.response,
        response: Response(
          statusCode: 400,
          data: "Cannot be /.",
          requestOptions: RequestOptions(path: ""),
        ),
      ));

      expect(find.byType(FloatingActionButton), findsOneWidget);
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(
        find.widgetWithText(SnackBar, "Bad Request: Cannot be /."),
        findsOneWidget,
      );
    });
    testWidgets('create', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final mockService = MockReviewService();
      final reviewState = ReviewState(mockService);
      final review = testReview();

      await tester
          .pumpWidget(wrapWithMaterial(const ReviewWidget(), reviewState));
      await tester.pumpAndSettle();

      final titleField = find.bySemanticsLabel('Title');
      await tester.enterText(titleField, review.title);

      final bodyField = find.bySemanticsLabel('Body');
      await tester.enterText(bodyField, review.body);
      await tester.pumpAndSettle();

      when(mockService.create(review.title, review.body))
          .thenAnswer((realInvocation) async => ReviewResp(review: review));

      expect(find.byType(FloatingActionButton), findsOneWidget);
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(
        find.widgetWithText(SnackBar, "Created Review"),
        findsOneWidget,
      );
    });
    testWidgets('update', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final mockService = MockReviewService();
      final review = testReview();
      final reviewState = ReviewState(mockService, review: review);

      await tester
          .pumpWidget(wrapWithMaterial(const ReviewWidget(), reviewState));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      when(mockService.update(
        review.user.username,
        review.slug,
        review.title,
        review.body,
      )).thenAnswer((realInvocation) async => ReviewResp(review: review));

      expect(find.byType(FloatingActionButton), findsOneWidget);
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(
        find.widgetWithText(SnackBar, "Updated Review"),
        findsOneWidget,
      );
    });
    testWidgets('delete', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final mockService = MockReviewService();
      final review = testReview();
      final reviewState = ReviewState(mockService, review: review);

      await tester
          .pumpWidget(wrapWithMaterial(const ReviewWidget(), reviewState));
      await tester.pumpAndSettle();

      when(mockService.delete(review.user.username, review.slug))
          .thenAnswer((realInvocation) async => null);

      final menuButton = find.byIcon(Icons.adaptive.more);
      expect(menuButton, findsOneWidget);
      await tester.tap(menuButton.first);
      await tester.pump();

      expect(find.text('Delete'), findsOneWidget);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // verify(mockService.delete(review.slug));
      // TODO fix
      // expect(
      //   find.widgetWithText(SnackBar, "Deleted Review"),
      //   findsOneWidget,
      // );
    });
  });
}
