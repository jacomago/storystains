import 'package:flutter/material.dart';
import 'package:storystains/common/utils/utils.dart';

class PositionEdit extends StatelessWidget {
  final ValueNotifier<int> positionController;

  const PositionEdit({Key? key, required this.positionController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: TextField(
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Position',
              hintText: 'ReviewEmotion position',
            ),
            style: context.headlineMedium,
            controller: TextEditingController(
              text: positionController.value.toStringAsFixed(0),
            ),
            onSubmitted: (value) {
              final newValue = double.tryParse(value);
              if (newValue != null && newValue != positionController.value) {
                positionController.value = newValue.clamp(0, 100) as int;
              }
            },
          ),
        ),
        Slider(
          value: positionController.value.toDouble(),
          min: 0,
          max: 100,
          divisions: 1,
          onChanged: (value) {
            positionController.value = value as int;
          },
        ),
      ],
    );
  }
}
