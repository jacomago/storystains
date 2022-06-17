import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storystains/common/widget/emotion_image.dart';
import 'package:storystains/features/emotions/emotion.dart';
import 'package:storystains/model/entity/emotion.dart';

class EmotionDialog extends StatefulWidget {
  const EmotionDialog({
    Key? key,
    required this.initialEmotion,
    this.restorationId,
  }) : super(key: key);
  final String? restorationId;
  final Emotion initialEmotion;

  @override
  State<StatefulWidget> createState() => _EmotionDialogState();
}

class _EmotionDialogState extends State<EmotionDialog> {
  late final ValueNotifier _selectedEmotion =
      ValueNotifier(widget.initialEmotion);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      clipBehavior: Clip.antiAlias,
      child: GridView.count(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        children: Provider.of<EmotionsState>(context).items.map((e) {
          return GestureDetector(
            child: Container(
              foregroundDecoration: _selectedEmotion.value == e
                  ? BoxDecoration(color: Colors.black.withAlpha(50))
                  : const BoxDecoration(),
              child: GridTile(
                footer: Text(e.name),
                child: EmotionImage(
                  emotion: e,
                  width: 100,
                  height: 100,
                ),
              ),
            ),
            onTap: () => {_chooseEmotion(e)},
          );
        }).toList(),
      ),
    );
  }

  void _chooseEmotion(Emotion e) {
    Navigator.pop(context, e);
  }
}