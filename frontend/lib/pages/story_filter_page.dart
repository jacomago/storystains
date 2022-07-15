import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../common/utils/utils.dart';
import '../common/widget/widget.dart';
import '../features/auth/auth.dart';
import '../features/reviews/reviews.dart';
import '../features/story/story.dart';
import '../routes/routes.dart';

/// A page of reviews filtered by story options
class StoryFilterPage extends StatelessWidget {
  /// constructor of the [StoryFilterPage]
  const StoryFilterPage({Key? key, this.query = const StoryQuery()})
      : super(key: key);

  /// Initial query to filter by
  final StoryQuery query;

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => ReviewsState(
              ReviewsService(),
              ReviewQuery(storyQuery: query),
            ),
          ),
          ChangeNotifierProvider(
            create: (_) => StoryState(StoryService(), query: query),
          ),
        ],
        child: const StoryFilter(),
      );
}

/// Widget for filtering a ReviewList by Story details
class StoryFilter extends StatelessWidget {
  /// Constructor for [StoryFilter]
  const StoryFilter({Key? key}) : super(key: key);

  Future<void> _goNewReview(
    BuildContext context,
    ReviewsState reviewsState,
  ) async {
    context.push(Routes.reviewNew).then((value) => context.pop());
  }

  void _onChanged(ReviewsState reviews, StoryState state) async {
    await reviews.refresh(ReviewQuery(storyQuery: state.query));
  }

  @override
  Widget build(BuildContext context) =>
      Consumer3<ReviewsState, StoryState, AuthState>(
        builder: (context, reviews, state, auth, _) => Scaffold(
          appBar: StainsAppBar(
            title: AppBarTitle(AppLocalizations.of(context)!.reviewList),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: StoryFormWidget(
                  state: state,
                  onChanged: () {
                    _onChanged(reviews, state);
                  },
                ),
              ),
              const Divider(),
              const Flexible(
                child: ReviewList(),
              ),
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
