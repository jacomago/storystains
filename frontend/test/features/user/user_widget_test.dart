import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storystains/common/constant/app_config.dart';
import 'package:storystains/common/utils/service_locator.dart';
import 'package:storystains/features/auth/auth.dart';
import 'package:storystains/features/emotions/emotion.dart';
import 'package:storystains/features/reviews/reviews_model.dart';
import 'package:storystains/features/reviews/reviews_service.dart';
import 'package:storystains/features/reviews/reviews_state.dart';
import 'package:storystains/features/user/user.dart';

import '../review/review.dart';
import 'user_widget_test.mocks.dart';

Widget wrapWithMaterial(Widget w, ReviewsState reviewsState) => MultiProvider(
      providers: [
        ChangeNotifierProvider<ReviewsState>(
          create: (_) => reviewsState,
        ),
        ChangeNotifierProvider<AuthState>(
          create: (_) => AuthState(AuthService()),
        ),
        ChangeNotifierProvider<EmotionsState>(
          create: (_) => EmotionsState(EmotionsService()),
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

@GenerateMocks([ReviewsService])
void main() {
  setUp(() {
    WidgetsFlutterBinding.ensureInitialized();
    ServiceLocator.setup();
  });
  tearDown(ServiceLocator.sl.reset);
  group('User Widget test', () {
    testWidgets('some data', (tester) async {
      SharedPreferences.setMockInitialValues({});

      final review = testReview(slug: 'randomtitle');
      final query = ReviewQuery(
        username: review.user.username,
      );
      final mockService = MockReviewsService();
      when(mockService.fetch(query: query)).thenAnswer(
        (realInvocation) async => [
          review,
        ],
      );
      when(mockService.fetch(query: query, offset: AppConfig.defaultLimit))
          .thenAnswer((realInvocation) async => []);

      final reviewsState = ReviewsState(
        mockService,
        query,
      );

      await tester.pumpWidget(wrapWithMaterial(
        UserWidget(
          user: review.user,
        ),
        reviewsState,
      ));
      await tester.pumpAndSettle();

      verify(mockService.fetch(query: query, offset: AppConfig.defaultLimit));

      expect(find.text(review.story.title), findsOneWidget);
      expect(find.text('by ${review.story.creator}'), findsOneWidget);
      expect(find.text(review.story.medium.name), findsOneWidget);
      expect(find.text('@${review.user.username}'), findsOneWidget);
    });
  });
}
