import 'package:storystains/features/mediums/medium.dart';
import 'package:storystains/features/story/story.dart';
import 'package:storystains/features/story/story_model.dart';

Story testStory({
  String? title,
}) =>
    Story(
      title: title ?? 'Dune',
      creator: 'David Lynch',
      medium: const Medium(name: 'Film'),
    );

Story emptyStory() => Story(
      creator: '',
      title: '/',
      medium: Medium.mediumDefault,
    );
