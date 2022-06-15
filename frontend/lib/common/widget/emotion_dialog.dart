import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:storystains/features/emotions/emotion_state.dart';
import 'package:storystains/model/entity/emotion.dart';

class RestorableEmotion extends RestorableValue<Emotion> {
  RestorableEmotion(Emotion defaultValue) : _defaultValue = defaultValue;

  final Emotion _defaultValue;
  @override
  Emotion createDefaultValue() => _defaultValue;

  @override
  void didUpdateValue(Emotion? oldValue) {
    assert(debugIsSerializableForRestoration(value.name));
    notifyListeners();
  }

  @override
  Emotion fromPrimitives(Object? data) => Emotion.fromName(data! as String);

  @override
  Object? toPrimitives() => value.name;
}

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

class _EmotionDialogState extends State<EmotionDialog> with RestorationMixin {
  late final RestorableEmotion _selectedEmotion =
      RestorableEmotion(widget.initialEmotion);

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
          return GridTile(
            footer: Text(e.name),
            child: GestureDetector(
              child: SvgPicture.network(e.icon_url),
              onTap: () => {_chooseEmotion(e)},
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  String? get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedEmotion, 'selected_date');
  }

  void _chooseEmotion(Emotion e) {
    Navigator.pop(context, _selectedEmotion.value);
  }
}
