import 'package:flutter/material.dart';
import '../utils/utils.dart';

/// Widget to change a percentage
class PositionEdit extends StatelessWidget {
  /// The controller of the int
  final ValueNotifier<int> positionController;

  /// Widget to change a percentage
  const PositionEdit({super.key, required this.positionController});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<int>(
        builder: (context, value, _) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 30,
              child: TextField(
                textAlign: TextAlign.center,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                style: context.labelLarge,
                controller: TextEditingController(
                  text: value.toStringAsFixed(0),
                ),
                onSubmitted: (newNewValue) {
                  final newValue = int.tryParse(newNewValue);
                  if (newValue != null && newValue != value) {
                    positionController.value = newValue.clamp(0, 100);
                  }
                },
              ),
            ),
            Expanded(
              child: Slider(
                activeColor: context.colors.secondary,
                value: value.toDouble(),
                max: 100.0,
                label: '${value.round()}',
                onChanged: (newValue) {
                  positionController.value = newValue.floor();
                },
              ),
            ),
          ],
        ),
        valueListenable: positionController,
      );
}
