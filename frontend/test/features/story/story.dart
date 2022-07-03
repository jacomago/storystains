import 'package:storystains/features/mediums/medium.dart';
import 'package:storystains/features/story/story_model.dart';
import 'package:storystains/features/story/story.dart';

Story testStory({
  String? title,
}) =>
    Story(
      title: title ?? "Dune",
      creator: 'David Lynch',
      medium: Medium(name: 'Film'),
    );
