import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storystains/features/mediums/medium.dart';
import 'package:storystains/features/story/story.dart';

import 'story.dart';
import 'story_widget_test.mocks.dart';

Widget wrapWithMaterial(Widget w, {MediumsState? mediumState}) => MultiProvider(
      providers: [
        ChangeNotifierProvider<MediumsState>(
          create: (_) => mediumState ?? MediumsState(MediumsService()),
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: w,
        ),
      ),
    );

@GenerateMocks([MediumsService])
void main() {
  setUp(() => {WidgetsFlutterBinding.ensureInitialized()});
  group("Edit review emotion", () {
    testWidgets('set title', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final state = StoryState(StoryService());
      await tester.pumpWidget(
        wrapWithMaterial(
          StoryEditWidget(
            state: state,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final titleField = find.bySemanticsLabel('Title');
      await tester.enterText(titleField, "/");

      expect(state.value!.title, "/");
    });
    testWidgets('set creator', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final state = StoryState(StoryService());
      await tester.pumpWidget(
        wrapWithMaterial(
          StoryEditWidget(
            state: state,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final creatorField = find.bySemanticsLabel('Creator');
      await tester.enterText(creatorField, "/");

      expect(state.value!.creator, "/");
    });
    testWidgets('set medium', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final state = StoryState(StoryService());

      // Setup mediums
      final mediumsService = MockMediumsService();
      final mediumsResp =
          MediumsResp(mediums: [Medium.mediumDefault, testStory().medium]);
      when(mediumsService.fetch())
          .thenAnswer((realInvocation) async => mediumsResp.mediums);
      final mediumState = MediumsState(mediumsService);

      await tester.pumpWidget(
        wrapWithMaterial(
          StoryEditWidget(
            state: state,
          ),
          mediumState: mediumState,
        ),
      );
      await tester.pumpAndSettle();

      final mediumField = find.text(Medium.mediumDefault.name);
      expect(mediumField, findsOneWidget);

      await tester.tap(mediumField);
      await tester.pumpAndSettle();

      final mediumSelect = find.text(mediumsResp.mediums[1].name);
      await tester.tap(mediumSelect.last);
      await tester.pumpAndSettle();

      expect(state.value!.medium, mediumsResp.mediums[1]);
    });
  });
}
