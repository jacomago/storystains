import 'package:flutter/material.dart';

import '../../../common/widget/widget.dart';
import '../story_model.dart';
import '../story_state.dart';

/// Widget for editing a [Story]
class SearchStoryResults extends StatelessWidget {
  /// Widget for editing a [Story]
  const SearchStoryResults({Key? key, required this.state}) : super(key: key);

  /// State of the [Story]
  final StoryState state;

  Widget _storiesList(AsyncSnapshot<List<Story>?> snapshot) => ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: snapshot.data!.length,
        itemBuilder: ((context, index) => _simpleStory(snapshot, index)),
      );

  Widget _simpleStory(AsyncSnapshot<List<Story>?> snapshot, int index) =>
      Column(
        children: [
          Text(snapshot.data![index].title),
          Text(snapshot.data![index].creator),
          Text(snapshot.data![index].medium.name),
        ],
      );

  @override
  Widget build(BuildContext context) => StreamBuilder(
        stream: state.searchResults.stream,
        builder: ((context, snapshot) {
          if (!snapshot.hasData) {
            return const LoadingMore();
          }

          return snapshot.connectionState == ConnectionState.waiting
              ? const LoadingMore()
              : _storiesList(snapshot as AsyncSnapshot<List<Story>?>);
        }),
      );
}
