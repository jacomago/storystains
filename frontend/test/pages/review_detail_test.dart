import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mockito/annotations.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storystains/features/auth/auth.dart';
import 'package:storystains/features/emotions/emotion.dart';
import 'package:storystains/features/review/review.dart';
import 'package:storystains/model/entity/review.dart';
import 'package:storystains/model/entity/user.dart';
import 'package:storystains/pages/review_detail.dart';

import 'review_detail_test.mocks.dart';

Widget wrapWithMaterial(
  Widget w,
  ReviewState reviewState,
  AuthState authState,
) =>
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ReviewState>(
          create: (_) => reviewState,
        ),
        ChangeNotifierProvider<EmotionsState>(
          create: (_) => EmotionsState(EmotionsService()),
        ),
        ChangeNotifierProvider<AuthState>(
          create: (_) => authState,
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: w,
        ),
      ),
    );

@GenerateMocks([ReviewService, AuthService])
void main() {
  setUp(() => {WidgetsFlutterBinding.ensureInitialized()});
  group("Read Review", () {
    testWidgets('fields exist', (tester) async {
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
          emotions: [],
          user: UserProfile(username: "username"),
        ),
      );
      await tester.pumpWidget(wrapWithMaterial(
        const ReviewDetailPage(),
        reviewState,
        AuthState(AuthService()),
      ));

      final titleField = find.bySemanticsLabel('Title');
      expect(titleField, findsOneWidget);
      expect(find.text('title'), findsOneWidget);

      expect(find.text('body'), findsOneWidget);

      expect(find.text("@username"), findsOneWidget);
      expect(
        find.text("Created At: ${DateFormat.yMMMMEEEEd().format(time)}"),
        findsOneWidget,
      );
      expect(
        find.text("Updated At: ${DateFormat.yMMMMEEEEd().format(time)}"),
        findsOneWidget,
      );
    });
  });
}

// TODO send review
