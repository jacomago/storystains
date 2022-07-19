import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../common/utils/utils.dart';
import '../../common/widget/widget.dart';
import 'emotion.dart';

/// Dialog window to pick an emotion and return it
class EmotionDialog extends StatefulWidget {
  /// Dialog window to pick an emotion and return it
  const EmotionDialog({
    Key? key,
    required this.initialEmotion,
    this.restorationId,
  }) : super(key: key);

  /// Id for restoration
  final String? restorationId;

  /// Current emotion chosen
  final Emotion initialEmotion;

  @override
  State<StatefulWidget> createState() => _EmotionDialogState();
}

class _EmotionDialogState extends State<EmotionDialog> {
  late final ValueNotifier<Emotion> _selectedEmotion =
      ValueNotifier(widget.initialEmotion);

  @override
  Widget build(BuildContext context) => Dialog(
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        clipBehavior: Clip.antiAlias,
        child: GridView.count(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: Provider.of<EmotionsState>(context)
              .items
              .map((e) => GestureDetector(
                    child: Container(
                      foregroundDecoration: _selectedEmotion.value == e
                          ? BoxDecoration(
                              color: Colors.black.withAlpha(50),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5)),
                            )
                          : const BoxDecoration(),
                      child: GridTile(
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: EmotionImageText(
                            emotion: e,
                            height: 75,
                          ),
                        ),
                      ),
                    ),
                    onTap: () => {_chooseEmotion(e)},
                  ))
              .toList(),
        ),
      );

  void _chooseEmotion(Emotion e) {
    Navigator.pop(context, e);
  }
}
