import 'package:flutter/material.dart';

/// Display loading sign when still loading
class LoadingMore extends StatelessWidget {
  /// Display loading sign when still loading
  const LoadingMore({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          width: 24,
          height: 24,
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: const CircularProgressIndicator(strokeWidth: 3),
        ),
      );
}
