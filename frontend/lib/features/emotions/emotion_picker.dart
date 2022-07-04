import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storystains/common/utils/utils.dart';
import 'package:storystains/common/widget/widget.dart';
import 'package:storystains/features/emotions/emotion.dart';

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
  late final ValueNotifier<Emotion> _selectedEmotion =
      ValueNotifier(widget.initialEmotion);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      clipBehavior: Clip.antiAlias,
      child: GridView.count(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        children: Provider.of<EmotionsState>(context).items.map((e) {
          return GestureDetector(
            child: Container(
              foregroundDecoration: _selectedEmotion.value == e
                  ? BoxDecoration(color: Colors.black.withAlpha(50))
                  : const BoxDecoration(),
              child: GridTile(
                footer: Text(
                  e.name,
                  textAlign: TextAlign.center,
                  style: context.caption,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: EmotionImage(
                    emotion: e,
                    width: 50,
                    height: 50,
                  ),
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
