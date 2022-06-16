import 'package:flutter/material.dart';
import 'package:storystains/common/utils/utils.dart';

class PositionEdit extends StatelessWidget {
  final ValueNotifier<int> positionController;

  const PositionEdit({Key? key, required this.positionController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 48,
          width: 64,
          child: TextField(
            textAlign: TextAlign.center,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.number,
            style: context.headlineMedium,
            controller: TextEditingController(
              text: positionController.value.toStringAsFixed(0),
            ),
            onSubmitted: (value) {
              final newValue = int.tryParse(value);
              if (newValue != null && newValue != positionController.value) {
                positionController.value = newValue.clamp(0, 100);
              }
            },
            maxLength: 2,
          ),
        ),
        Slider(
          value: positionController.value.toDouble(),
          min: 0,
          max: 100,
          divisions: 1,
          onChanged: (value) {
            positionController.value = value.floor();
          },
        ),
      ],
    );
  }
}
