import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storystains/features/emotions/emotion.dart';
import 'package:storystains/features/review/review_edit.dart';
import 'package:storystains/features/review/review.dart';
import 'package:storystains/model/entity/review.dart';
import 'package:storystains/model/entity/user.dart';

import '../../model/review.dart';
import '../reviews/review_list_test.dart';
import 'review_edit_test.mocks.dart';

Widget wrapWithMaterial(Widget w, ReviewState reviewState) => MultiProvider(
      providers: [
        ChangeNotifierProvider<ReviewState>(
          create: (_) => reviewState,
        ),
        ChangeNotifierProvider<EmotionsState>(
          create: (_) => EmotionsState(EmotionsService()),
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: w,
        ),
      ),
    );

@GenerateMocks([ReviewService])
void main() {
  setUp(() => {WidgetsFlutterBinding.ensureInitialized()});
  group("Edit Review", () {
    testWidgets('fields exist', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final review = testReview();

      final reviewState = ReviewState(ReviewService(), review);
      await tester
          .pumpWidget(wrapWithMaterial(const ReviewEditPage(), reviewState));

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
      final reviewState = ReviewState(mockService, review);
      await tester
          .pumpWidget(wrapWithMaterial(const ReviewEditPage(), reviewState));
      await tester.pumpAndSettle();

      when(mockService.update(review.title, review.slug, review.body))
          .thenThrow(DioError(
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
          .pumpWidget(wrapWithMaterial(const ReviewEditPage(), reviewState));
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
  });
}

// TODO send review
