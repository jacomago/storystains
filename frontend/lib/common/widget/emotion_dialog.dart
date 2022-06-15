import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Emotion {
  Emotion({required this.name, required this.icon});
  final String name;
  final Icon icon;

  static fromName(String s) {
    return Emotion(name: s, icon: Icon(Icons.circle));
  }
}

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

  List<Emotion> _emotions() {
    return [
      Emotion(name: "Joy", icon: Icon(Icons.circle)),
      Emotion(name: "Anger", icon: Icon(Icons.circle)),
      Emotion(name: "Hope", icon: Icon(Icons.circle)),
      Emotion(name: "Blah", icon: Icon(Icons.circle)),
      Emotion(name: "d", icon: Icon(Icons.circle)),
      Emotion(name: "Jody", icon: Icon(Icons.circle)),
      Emotion(name: "Jody", icon: Icon(Icons.circle)),
      Emotion(name: "Joly", icon: Icon(Icons.circle)),
      Emotion(name: "Jojy", icon: Icon(Icons.circle)),
      Emotion(name: "Joyy", icon: Icon(Icons.circle)),
      Emotion(name: "Joy", icon: Icon(Icons.circle)),
      Emotion(name: "Joy", icon: Icon(Icons.circle)),
      Emotion(name: "Joy", icon: Icon(Icons.circle)),
      Emotion(name: "Joy", icon: Icon(Icons.circle)),
      Emotion(name: "Joy", icon: Icon(Icons.circle)),
      Emotion(name: "Joy", icon: Icon(Icons.circle)),
      Emotion(name: "Joy", icon: Icon(Icons.circle)),
      Emotion(name: "Joy", icon: Icon(Icons.circle)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        clipBehavior: Clip.antiAlias,
        child: Container(
          child: GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: _emotions().map((e) {
              return GridTile(
                footer: Text(e.name),
                child: IconButton(
                  icon: e.icon,
                  onPressed: () => {_chooseEmotion(e)},
                ),
              );
            }).toList(),
          ),
        ));
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
