import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../common/utils/utils.dart';
import '../../../common/widget/widget.dart';
import '../story.dart';

/// Widget for editing a [Story]
class SearchStoryResults extends StatelessWidget {
  /// Widget for editing a [Story]
  const SearchStoryResults({Key? key, required this.state}) : super(key: key);

  /// State of the [Story]
  final StoryState state;

  Widget _storiesList(
    BuildContext context,
    AsyncSnapshot<List<Story>?> snapshot,
  ) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.searchResults,
            style: context.labelMedium,
          ),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: snapshot.data!.length,
            shrinkWrap: true,
            itemBuilder: ((context, index) => _simpleStory(snapshot, index)),
          ),
        ],
      );

  Widget _simpleStory(AsyncSnapshot<List<Story>?> snapshot, int index) =>
      GestureDetector(
        onTap: () => state.pickStory(snapshot.data![index]),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: CardStory(
            story: snapshot.data![index],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => StreamBuilder(
        stream: state.searchResults.stream,
        builder: ((context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingMore();
          }

          if ((snapshot.data as List<Story>).isNotEmpty) {
            return _storiesList(
              context,
              snapshot as AsyncSnapshot<List<Story>?>,
            );
          }

          return Container();
        }),
      );
}
