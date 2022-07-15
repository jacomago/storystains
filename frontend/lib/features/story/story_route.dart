import 'package:flutter/material.dart';

import 'story_model.dart';

/// url route for a [StoryQuery]
extension PageRoute on StoryQuery {
  /// url route for a [StoryQuery]
  MaterialPageRoute<StoryQuery> route(
    String routeName,
    Widget Function(StoryQuery) builder,
  ) {
    var map = <String, String>{};

    if (title != null) {
      map['title'] = title!;
    }
    if (creator != null) {
      map['creator'] = creator!;
    }
    if (medium != null) {
      map['medium'] = medium!.name;
    }

    return MaterialPageRoute<StoryQuery>(
      settings: RouteSettings(
        name: Uri(path: '$routeName/', queryParameters: map).toString(),
      ),
      builder: (context) => builder(this),
    );
  }
}
