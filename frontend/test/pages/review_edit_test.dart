import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storystains/common/widget/review_edit.dart';
import 'package:storystains/features/review/review.dart';
import 'package:storystains/model/entity/review.dart';
import 'package:storystains/model/entity/user.dart';

import 'review_edit_test.mocks.dart';

Widget wrapWithMaterial(Widget w, ReviewState reviewState) =>
    ChangeNotifierProvider<ReviewState>(
      create: (_) => reviewState,
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
    testWidgets('Edit', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final time = DateTime.now();
      final reviewState = ReviewState(
          ReviewService(),
          Review(
              body: "body",
              createdAt: time,
              slug: "title",
              title: "title",
              updatedAt: time,
              user: UserProfile(username: "username")));
      await tester
          .pumpWidget(wrapWithMaterial(const ReviewEditPage(), reviewState));

      final titleField = find.bySemanticsLabel('Title');
      expect(titleField, findsOneWidget);
      expect(find.text('title'), findsOneWidget);

      final bodyField = find.bySemanticsLabel('Body');
      expect(bodyField, findsOneWidget);
      expect(find.text('body'), findsOneWidget);

      await tester.enterText(titleField, "title1");
      await tester.pumpAndSettle();
      expect(find.text('title1'), findsOneWidget);

      await tester.enterText(bodyField, "body1");
      await tester.pumpAndSettle();
      expect(find.text('body1'), findsOneWidget);
    });
    testWidgets('error message on bad info', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final time = DateTime.now();
      final mockService = MockReviewService();
      final reviewState = ReviewState(
          mockService,
          Review(
              body: "",
              createdAt: time,
              slug: "title",
              title: "",
              updatedAt: time,
              user: UserProfile(username: "username")));
      await tester
          .pumpWidget(wrapWithMaterial(const ReviewEditPage(), reviewState));
      await tester.pumpAndSettle();

      when(mockService.create("", "")).thenAnswer((realInvocation) async =>
          Response(
              requestOptions: RequestOptions(path: ""),
              statusCode: 400,
              statusMessage: "Cannot be empty."));

      expect(find.byType(FloatingActionButton), findsOneWidget);
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      print(tester.allWidgets);
    });
  });
}

// TODO send review
// TODO see failure message
