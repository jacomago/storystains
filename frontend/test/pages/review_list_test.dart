import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storystains/common/widget/review_list.dart';
import 'package:storystains/features/reviews/reviews_service.dart';
import 'package:storystains/features/reviews/reviews_state.dart';
import 'package:storystains/model/resp/reviews_resp.dart';

import 'review_list_test.mocks.dart';

Widget wrapWithMaterial(Widget w, ReviewsState reviewsState) =>
    ChangeNotifierProvider<ReviewsState>(
      create: (_) => reviewsState,
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
    testWidgets('no data', (tester) async {
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

      final mockService = ReviewsService();
      final reviewsState = ReviewsState(
        mockService,
      );
      await tester
          .pumpWidget(wrapWithMaterial(const ReviewsPage(), reviewsState));
      await tester.pumpAndSettle();

      expect(find.text('Fetching data failed'), findsOneWidget);
    });
  });
}

// TODO load review
// TODO edit review
// TODO send review
// TODO see failure message
