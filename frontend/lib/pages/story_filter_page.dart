import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../common/utils/utils.dart';
import '../common/widget/widget.dart';
import '../features/auth/auth.dart';
import '../features/reviews/reviews.dart';
import '../features/story/story.dart';
import '../routes/routes.dart';

/// The home page of the app
class StoryFilterPage extends StatelessWidget {
  /// The home page of the app
  const StoryFilterPage({Key? key, required this.query}) : super(key: key);

  /// Initial query to filter by
  final StoryQuery query;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (_) => ReviewsState(
          ReviewsService(),
          ReviewQuery(storyQuery: query),
        ),
        child: StoryFilter(),
      );
}

/// The page of a user
class StoryFilter extends StatelessWidget {
  /// The page of a user
  StoryFilter({Key? key, StoryQuery? query})
      : state = StoryState(StoryService(), query: query),
        super(key: key);

  /// State used as a StoryQuery controller
  late final StoryState state;

  Future<void> _goNewReview(
    BuildContext context,
    ReviewsState reviewsState,
  ) async {
    context.push(Routes.reviewNew).then((value) => context.pop());
  }

  void _onChanged(ReviewsState reviews) async {
    if (state.value == null) {
      return;
    }
    await reviews.refresh(ReviewQuery(storyQuery: state.query));
  }

  @override
  Widget build(BuildContext context) => Consumer2<ReviewsState, AuthState>(
        builder: (context, reviews, auth, _) => Scaffold(
          appBar: StainsAppBar(
            title: AppBarTitle(AppLocalizations.of(context)!.reviewList),
          ),
          body: Column(
            children: [
              StoryFormWidget(
                state: state,
                onChanged: () {
                  _onChanged(reviews);
                },
              ),
              const ReviewList(),
            ],
          ),
          floatingActionButton: auth.isAuthenticated
              ? CustomFloatingButton(
                  onPressed: () => _goNewReview(context, reviews),
                  icon: Icons.mode_edit_outline_sharp,
                )
              : null,
        ),
      );
}
