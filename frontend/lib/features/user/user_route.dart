import 'package:flutter/material.dart';

import 'user_model.dart';

/// url route for a [UserProfile]
extension PageRoute on UserProfile {
  /// url route for a [UserProfile]
  MaterialPageRoute<UserProfile> route(
    String routeName,
    Widget Function(UserProfile) builder,
  ) =>
      MaterialPageRoute<UserProfile>(
        settings: RouteSettings(
          name: '$routeName/$this.username',
        ),
        builder: (context) => builder(this),
      );
}
