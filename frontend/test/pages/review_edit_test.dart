import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storystains/common/widget/review_edit.dart';
import 'package:storystains/features/review/review.dart';
import 'package:storystains/model/entity/review.dart';

Widget wrapWithMaterial(Widget w, ReviewState reviewState) =>
    ChangeNotifierProvider<ReviewState>(
      create: (_) => reviewState,
      child: MaterialApp(
        home: Scaffold(
          body: w,
        ),
      ),
    );

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
              updatedAt: time));
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

      var actionButton = find.byElementType(FloatingActionButton);
      expect(actionButton, findsOneWidget);

      await tester.tap(actionButton);
      await tester.pumpAndSettle();

      var snackBar = find.byElementType(SnackBar);
      expect(snackBar, findsOneWidget);

    });
  });
}

// TODO load review
// TODO edit review
// TODO send review
// TODO see failure message
