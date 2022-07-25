import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storystains/features/emotions/emotion.dart';
import 'package:storystains/features/review/review.dart';
import 'package:storystains/features/review_emotion/review_emotion.dart';

import '../../common/errors.dart';
import '../../common/image_mock_http.dart';
import '../emotions/emotion.dart';
import '../review/review.dart';
import 'review_emotion.dart';
import 'review_emotion_edit_test.mocks.dart';

Widget wrapWithMaterial(
  Widget w, {
  EmotionsState? emotionsState,
  ReviewState? reviewState,
}) =>
    MultiProvider(
      providers: [
        ChangeNotifierProvider<EmotionsState>(
          create: (_) => emotionsState ?? EmotionsState(EmotionsService()),
        ),
        ChangeNotifierProvider<ReviewState>(
          create: (_) =>
              reviewState ??
              ReviewState(
                ReviewService(),
                review: testReview(),
              ),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        locale: const Locale('en'),
        home: Scaffold(
          body: w,
        ),
      ),
    );

@GenerateMocks([ReviewEmotionService])
void main() {
  setUp(() => {WidgetsFlutterBinding.ensureInitialized()});
  group('Edit review emotion', () {
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
            state: ReviewEmotionState(
              ReviewEmotionService(),
              emotion: testEmotion(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    });
    testWidgets('test cancel button', (tester) async {
      SharedPreferences.setMockInitialValues({});
      var ok = false;
      okHandler(_) {
        ok = true;
      }

      var cancel = false;
      cancelHandler() {
        cancel = true;
      }

      var delete = false;
      deleteHandler() {
        delete = true;
      }

      await tester.pumpWidget(
        wrapWithMaterial(
          ReviewEmotionEdit(
            cancelHandler: cancelHandler,
            okHandler: okHandler,
            deleteHandler: deleteHandler,
            state: ReviewEmotionState(
              ReviewEmotionService(),
              emotion: testEmotion(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(OutlinedButton, 'Cancel'));
      await tester.pump();

      expect(ok, false);
      expect(cancel, true);
      expect(delete, false);
    });
    testWidgets('test create', (tester) async {
      SharedPreferences.setMockInitialValues({});
      var ok = false;
      okHandler(_) {
        ok = true;
      }

      var cancel = false;
      cancelHandler() {
        cancel = true;
      }

      var delete = false;
      deleteHandler() {
        delete = true;
      }

      final review = testReview();
      final reviewState = ReviewState(ReviewService(), review: review);
      final emotion = testEmotion();
      final service = MockReviewEmotionService();

      await tester.pumpWidget(
        wrapWithMaterial(
          ReviewEmotionEdit(
            cancelHandler: cancelHandler,
            okHandler: okHandler,
            deleteHandler: deleteHandler,
            state: ReviewEmotionState(
              service,
              emotion: emotion,
            ),
          ),
          reviewState: reviewState,
        ),
      );
      await tester.pumpAndSettle();

      final reviewEmotion = testReviewEmotion(
        position: 10,
        notes: 'Random Notes',
        emotion: emotion,
      );

      // TODO find a way to measure the increment programatically
      const sliderIncSize = 5.8;
      final posChanger = find.byType(Slider);
      expect(posChanger, findsOneWidget);
      await tester.drag(
        posChanger.first,
        Offset(sliderIncSize * (reviewEmotion.position - 50), 0),
      );
      await tester.pumpAndSettle();

      final notes = find.bySemanticsLabel('Notes Field');
      await tester.enterText(notes.first, reviewEmotion.notes!);

      when(service.create(review, reviewEmotion)).thenAnswer(
        (realInvocation) async => ReviewEmotionResp(
          reviewEmotion: reviewEmotion,
        ),
      );

      await tester.pump();
      final okButton = find.widgetWithText(ElevatedButton, 'OK');
      expect(okButton, findsOneWidget);

      await tester.tap(okButton.first);
      await tester.pump();

      verify(service.create(review, reviewEmotion));
      expect(
        find.widgetWithText(SnackBar, 'Created ReviewEmotion'),
        findsOneWidget,
      );

      expect(ok, true);
      expect(cancel, false);
      expect(delete, false);
    });
    testWidgets('test update', (tester) async {
      SharedPreferences.setMockInitialValues({});
      var ok = false;
      var cancel = false;
      okHandler(_) {
        ok = true;
      }

      cancelHandler() {
        cancel = true;
      }

      var delete = false;
      deleteHandler() {
        delete = true;
      }

      final review = testReview();
      final reviewState = ReviewState(ReviewService(), review: review);
      final emotion = testEmotion(name: 'randomemotion');
      final service = MockReviewEmotionService();
      final reviewEmotion = testReviewEmotion();

      await tester.pumpWidget(
        wrapWithMaterial(
          ReviewEmotionEdit(
            cancelHandler: cancelHandler,
            okHandler: okHandler,
            deleteHandler: deleteHandler,
            state: ReviewEmotionState(
              service,
              emotion: emotion,
              reviewEmotion: reviewEmotion,
            ),
          ),
          reviewState: reviewState,
        ),
      );
      await tester.pumpAndSettle();

      final newReviewEmotion = testReviewEmotion(
        position: 10,
        notes: 'Random Notes',
        emotion: emotion,
      );

      // TODO find a way to measure the increment programatically
      const sliderIncSize = 5.8;
      final posChanger = find.byType(Slider);
      expect(posChanger, findsOneWidget);
      await tester.drag(
        posChanger.first,
        Offset(sliderIncSize * (newReviewEmotion.position - 50), 0),
      );
      await tester.pumpAndSettle();

      final notes = find.bySemanticsLabel('Notes Field');
      await tester.enterText(notes.first, newReviewEmotion.notes!);

      when(service.update(
        review,
        reviewEmotion.position,
        newReviewEmotion,
      )).thenAnswer(
        (realInvocation) async => ReviewEmotionResp(
          reviewEmotion: newReviewEmotion,
        ),
      );

      await tester.pump();
      final okButton = find.widgetWithText(ElevatedButton, 'OK');
      expect(okButton, findsOneWidget);

      await tester.tap(okButton.first);
      await tester.pump();

      verify(service.update(
        review,
        reviewEmotion.position,
        newReviewEmotion,
      ));
      expect(
        find.widgetWithText(SnackBar, 'Updated ReviewEmotion'),
        findsOneWidget,
      );

      expect(ok, true);
      expect(cancel, false);
      expect(delete, false);
    });
    testWidgets('test error message', (tester) async {
      SharedPreferences.setMockInitialValues({});
      var ok = false;
      var cancel = false;
      okHandler(_) {
        ok = true;
      }

      cancelHandler() {
        cancel = true;
      }

      var delete = false;
      deleteHandler() {
        delete = true;
      }

      final review = testReview();
      final reviewState = ReviewState(ReviewService(), review: review);
      final emotion = testEmotion();
      final service = MockReviewEmotionService();

      final reviewEmotion = testReviewEmotion(
        position: 10,
        notes: 'Random Notes',
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
            state: reviewEmotionState,
          ),
          reviewState: reviewState,
        ),
      );
      await tester.pumpAndSettle();

      when(service.update(review, reviewEmotion.position, reviewEmotion))
          .thenThrow(testApiError(400, 'Error message.'));

      await tester.pump();
      final okButton = find.widgetWithText(ElevatedButton, 'OK');
      expect(okButton, findsOneWidget);

      await tester.tap(okButton.first);
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(
        find.widgetWithText(SnackBar, 'Bad Request: Error message.'),
        findsOneWidget,
      );

      expect(ok, false);
      expect(cancel, true);
      expect(delete, false);
    });
    testWidgets('test delete', (tester) async {
      SharedPreferences.setMockInitialValues({});
      var ok = false;
      var cancel = false;
      var delete = false;
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
      final reviewState = ReviewState(ReviewService(), review: review);
      final emotion = testEmotion(name: 'randomemotion');
      final service = MockReviewEmotionService();
      final reviewEmotion = testReviewEmotion();

      await tester.pumpWidget(
        wrapWithMaterial(
          ReviewEmotionEdit(
            cancelHandler: cancelHandler,
            okHandler: okHandler,
            deleteHandler: deleteHandler,
            state: ReviewEmotionState(
              service,
              emotion: emotion,
              reviewEmotion: reviewEmotion,
            ),
          ),
          reviewState: reviewState,
        ),
      );
      await tester.pumpAndSettle();
      when(service.delete(
        review,
        reviewEmotion.position,
      )).thenAnswer((realInvocation) async => {});

      await tester.pump();
      final deleteButton = find.widgetWithText(ElevatedButton, 'Delete');
      expect(deleteButton, findsOneWidget);

      await tester.tap(deleteButton.first);
      await tester.pump();

      verify(service.delete(
        review,
        reviewEmotion.position,
      ));
      expect(
        find.widgetWithText(SnackBar, 'Deleted ReviewEmotion'),
        findsOneWidget,
      );

      expect(ok, false);
      expect(cancel, false);
      expect(delete, true);
    });
  });
}
