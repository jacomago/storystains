import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storystains/features/emotions/emotion.dart';
import 'package:storystains/features/review/review.dart';
import 'package:storystains/features/review_emotion/review_emotion.dart';
import 'package:storystains/model/resp/review_emotion_resp.dart';

import 'dart:io' as io;
import '../../common/errors.dart';
import '../../common/image_mock_http.dart';
import '../../model/emotion.dart';
import '../../model/review.dart';
import '../../model/review_emotion.dart';
import 'review_emotion_edit_test.mocks.dart';

Widget wrapWithMaterial(
  Widget w, {
  EmotionsState? emotionsState,
  ReviewEmotionState? reviewEmotionState,
  ReviewState? reviewState,
}) =>
    MultiProvider(
      providers: [
        ChangeNotifierProvider<EmotionsState>(
          create: (_) => emotionsState ?? EmotionsState(EmotionsService()),
        ),
        ChangeNotifierProvider<ReviewEmotionState>(
          create: (_) =>
              reviewEmotionState ??
              ReviewEmotionState(
                ReviewEmotionService(),
                emotion: testEmotion(),
              ),
        ),
        ChangeNotifierProvider<ReviewState>(
          create: (_) =>
              reviewState ??
              ReviewState(
                ReviewService(),
                testReview(),
              ),
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: w,
        ),
      ),
    );

@GenerateMocks([ReviewEmotionService])
void main() {
  setUp(() => {WidgetsFlutterBinding.ensureInitialized()});
  group("Edit review emotion", () {
    setUp(() {
      // Only needs to be done once since the HttpClient generated
      // by this override is cached as a static singleton.
      io.HttpOverrides.global = TestHttpOverrides();
    });

    testWidgets('minimal data smoke test', (tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        wrapWithMaterial(
          ReviewEmotionEdit(
            // ignore: no-empty-block
            cancelHandler: () {},
            // ignore: no-empty-block
            okHandler: (_) {},
            // ignore: no-empty-block
            deleteHandler: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
    });
    testWidgets('test cancel button', (tester) async {
      SharedPreferences.setMockInitialValues({});
      bool ok = false;
      okHandler(_) {
        ok = true;
      }

      bool cancel = false;
      cancelHandler() {
        cancel = true;
      }

      bool delete = false;
      deleteHandler() {
        delete = true;
      }

      await tester.pumpWidget(
        wrapWithMaterial(
          ReviewEmotionEdit(
            cancelHandler: cancelHandler,
            okHandler: okHandler,
            deleteHandler: deleteHandler,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(OutlinedButton, "Cancel"));
      await tester.pump();

      expect(ok, false);
      expect(cancel, true);
      expect(delete, false);
    });
    testWidgets('test create', (tester) async {
      SharedPreferences.setMockInitialValues({});
      bool ok = false;
      okHandler(_) {
        ok = true;
      }

      bool cancel = false;
      cancelHandler() {
        cancel = true;
      }

      bool delete = false;
      deleteHandler() {
        delete = true;
      }

      final review = testReview();
      final reviewState = ReviewState(ReviewService(), review);
      final emotion = testEmotion();
      final service = MockReviewEmotionService();

      await tester.pumpWidget(
        wrapWithMaterial(
          ReviewEmotionEdit(
            cancelHandler: cancelHandler,
            okHandler: okHandler,
            deleteHandler: deleteHandler,
          ),
          reviewState: reviewState,
          reviewEmotionState: ReviewEmotionState(
            service,
            emotion: emotion,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final reviewEmotion = testReviewEmotion(
        position: 10,
        notes: "Random Notes",
        emotion: emotion,
      );

      const sliderIncSize = 4.5;
      final posChanger = find.byType(Slider);
      expect(posChanger, findsOneWidget);
      await tester.drag(
        posChanger.first,
        Offset(sliderIncSize * (reviewEmotion.position - 50), 0),
      );
      await tester.pumpAndSettle();

      final notes = find.bySemanticsLabel("Notes");
      await tester.enterText(notes.first, reviewEmotion.notes);

      when(service.create(review.slug, reviewEmotion)).thenAnswer(
        (realInvocation) async => ReviewEmotionResp(
          reviewEmotion: reviewEmotion,
        ),
      );

      await tester.pump();
      final okButton = find.widgetWithText(ElevatedButton, "OK");
      expect(okButton, findsOneWidget);

      await tester.tap(okButton.first);
      await tester.pump();

      verify(service.create(review.slug, reviewEmotion));
      expect(
        find.widgetWithText(SnackBar, "Created ReviewEmotion"),
        findsOneWidget,
      );

      expect(ok, true);
      expect(cancel, false);
      expect(delete, false);
    });
    testWidgets('test update', (tester) async {
      SharedPreferences.setMockInitialValues({});
      bool ok = false;
      bool cancel = false;
      okHandler(_) {
        ok = true;
      }

      cancelHandler() {
        cancel = true;
      }

      bool delete = false;
      deleteHandler() {
        delete = true;
      }

      final review = testReview();
      final reviewState = ReviewState(ReviewService(), review);
      final emotion = testEmotion(name: "randomemotion");
      final service = MockReviewEmotionService();
      final reviewEmotion = testReviewEmotion();

      await tester.pumpWidget(
        wrapWithMaterial(
          ReviewEmotionEdit(
            cancelHandler: cancelHandler,
            okHandler: okHandler,
            deleteHandler: deleteHandler,
          ),
          reviewState: reviewState,
          reviewEmotionState: ReviewEmotionState(
            service,
            emotion: emotion,
            reviewEmotion: reviewEmotion,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final newReviewEmotion = testReviewEmotion(
        position: 10,
        notes: "Random Notes",
        emotion: emotion,
      );

      const sliderIncSize = 4.5;
      final posChanger = find.byType(Slider);
      expect(posChanger, findsOneWidget);
      await tester.drag(
        posChanger.first,
        Offset(sliderIncSize * (newReviewEmotion.position - 50), 0),
      );
      await tester.pumpAndSettle();

      final notes = find.bySemanticsLabel("Notes");
      await tester.enterText(notes.first, newReviewEmotion.notes);

      when(service.update(
        review.slug,
        reviewEmotion.position,
        newReviewEmotion,
      )).thenAnswer(
        (realInvocation) async => ReviewEmotionResp(
          reviewEmotion: newReviewEmotion,
        ),
      );

      await tester.pump();
      final okButton = find.widgetWithText(ElevatedButton, "OK");
      expect(okButton, findsOneWidget);

      await tester.tap(okButton.first);
      await tester.pump();

      verify(service.update(
        review.slug,
        reviewEmotion.position,
        newReviewEmotion,
      ));
      expect(
        find.widgetWithText(SnackBar, "Updated ReviewEmotion"),
        findsOneWidget,
      );

      expect(ok, true);
      expect(cancel, false);
      expect(delete, false);
    });
    testWidgets('test error message', (tester) async {
      SharedPreferences.setMockInitialValues({});
      bool ok = false;
      bool cancel = false;
      okHandler(_) {
        ok = true;
      }

      cancelHandler() {
        cancel = true;
      }

      bool delete = false;
      deleteHandler() {
        delete = true;
      }

      final review = testReview();
      final reviewState = ReviewState(ReviewService(), review);
      final emotion = testEmotion();
      final service = MockReviewEmotionService();

      final reviewEmotion = testReviewEmotion(
        position: 10,
        notes: "Random Notes",
        emotion: emotion,
      );

      final reviewEmotionState = ReviewEmotionState(
        service,
        emotion: emotion,
        reviewEmotion: reviewEmotion,
      );
      await tester.pumpWidget(
        wrapWithMaterial(
          ReviewEmotionEdit(
            cancelHandler: cancelHandler,
            okHandler: okHandler,
            deleteHandler: deleteHandler,
          ),
          reviewState: reviewState,
          reviewEmotionState: reviewEmotionState,
        ),
      );
      await tester.pumpAndSettle();

      when(service.update(review.slug, reviewEmotion.position, reviewEmotion))
          .thenThrow(testApiError(400, 'Error message.'));

      await tester.pump();
      final okButton = find.widgetWithText(ElevatedButton, "OK");
      expect(okButton, findsOneWidget);

      await tester.tap(okButton.first);
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(
        find.widgetWithText(SnackBar, "Bad Request: Error message."),
        findsOneWidget,
      );

      expect(ok, false);
      expect(cancel, true);
      expect(delete, false);
    });
    testWidgets('test delete', (tester) async {
      SharedPreferences.setMockInitialValues({});
      bool ok = false;
      bool cancel = false;
      bool delete = false;
      deleteHandler() {
        delete = true;
      }

      okHandler(_) {
        ok = true;
      }

      cancelHandler() {
        cancel = true;
      }

      final review = testReview();
      final reviewState = ReviewState(ReviewService(), review);
      final emotion = testEmotion(name: "randomemotion");
      final service = MockReviewEmotionService();
      final reviewEmotion = testReviewEmotion();

      await tester.pumpWidget(
        wrapWithMaterial(
          ReviewEmotionEdit(
            cancelHandler: cancelHandler,
            okHandler: okHandler,
            deleteHandler: deleteHandler,
          ),
          reviewState: reviewState,
          reviewEmotionState: ReviewEmotionState(
            service,
            emotion: emotion,
            reviewEmotion: reviewEmotion,
          ),
        ),
      );
      await tester.pumpAndSettle();
      when(service.delete(
        review.slug,
        reviewEmotion.position,
      )).thenAnswer(
        (realInvocation) async => null,
      );

      await tester.pump();
      final deleteButton = find.widgetWithText(ElevatedButton, "Delete");
      expect(deleteButton, findsOneWidget);

      await tester.tap(deleteButton.first);
      await tester.pump();

      verify(service.delete(
        review.slug,
        reviewEmotion.position,
      ));
      expect(
        find.widgetWithText(SnackBar, "Deleted ReviewEmotion"),
        findsOneWidget,
      );

      expect(ok, false);
      expect(cancel, false);
      expect(delete, true);
    });
  });
}
