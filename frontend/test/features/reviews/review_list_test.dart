import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storystains/common/constant/app_config.dart';
import 'package:storystains/features/emotions/emotion.dart';
import 'package:storystains/features/reviews/review_list.dart';
import 'package:storystains/features/reviews/reviews_service.dart';
import 'package:storystains/features/reviews/reviews_state.dart';

import '../../model/review.dart';
import 'review_list_test.mocks.dart';

Widget wrapWithMaterial(Widget w, ReviewsState reviewsState) => MultiProvider(
      providers: [
        ChangeNotifierProvider<ReviewsState>(
          create: (_) => reviewsState,
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

@GenerateMocks([ReviewsService])
void main() {
  setUp(() => {WidgetsFlutterBinding.ensureInitialized()});
  group("Refresh Reviews Page", () {
    testWidgets('fail network', (tester) async {
      SharedPreferences.setMockInitialValues({});

      final mockService = ReviewsService();
      final reviewsState = ReviewsState(
        mockService,
      );
      await tester
          .pumpWidget(wrapWithMaterial(const ReviewsPage(), reviewsState));
      await tester.pumpAndSettle();

      expect(find.text('Fetching data failed'), findsOneWidget);
    });
    testWidgets('no data', (tester) async {
      SharedPreferences.setMockInitialValues({});

      final mockService = MockReviewsService();

      when(mockService.fetch()).thenAnswer((realInvocation) async => []);
      final reviewsState = ReviewsState(
        mockService,
      );

      await tester
          .pumpWidget(wrapWithMaterial(const ReviewsPage(), reviewsState));
      await tester.pumpAndSettle();

      expect(find.text('No data'), findsOneWidget);
    });
    testWidgets('some data', (tester) async {
      SharedPreferences.setMockInitialValues({});

      final review = testReview(slug: "randomtitle");

      final mockService = MockReviewsService();
      when(mockService.fetch()).thenAnswer((realInvocation) async => [review]);
      when(mockService.fetch(offset: AppConfig.defaultLimit))
          .thenAnswer((realInvocation) async => []);

      final reviewsState = ReviewsState(
        mockService,
      );

      await tester
          .pumpWidget(wrapWithMaterial(const ReviewsPage(), reviewsState));
      await tester.pumpAndSettle();

      expect(find.text(review.title), findsOneWidget);
      expect(find.text("@${review.user.username}"), findsOneWidget);
    });
    testWidgets('refresh', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final review =
          testReview(slug: "randomtitle", username: "randomusername");

      final mockService = MockReviewsService();
      when(mockService.fetch()).thenAnswer((realInvocation) async => []);

      await tester.pumpWidget(wrapWithMaterial(
        const ReviewsPage(),
        ReviewsState(
          mockService,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text(review.title), findsNothing);

      when(mockService.fetch()).thenAnswer((realInvocation) async => [review]);
      when(mockService.fetch(offset: AppConfig.defaultLimit))
          .thenAnswer((realInvocation) async => []);

      expect(find.text("Refresh"), findsOneWidget);
      await tester.tap(find.widgetWithText(OutlinedButton, "Refresh"));
      await tester.pumpAndSettle();

      verify(mockService.fetch());

      expect(find.text(review.title), findsOneWidget);
      expect(find.text("@${review.user.username}"), findsOneWidget);
    });
  });
}
