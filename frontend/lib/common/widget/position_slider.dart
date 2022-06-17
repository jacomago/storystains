import 'package:flutter/material.dart';
import 'package:storystains/common/utils/utils.dart';

class PositionEdit extends StatelessWidget {
  final ValueNotifier<int> positionController;

  const PositionEdit({Key? key, required this.positionController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TextField(
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
        Expanded(
          child: Slider(
            value: positionController.value.toDouble(),
            min: 0.0,
            max: 100.0,
            onChanged: (value) {
              positionController.value = value.floor();
            },
          ),
        ),
      ],
    );
  }
}
