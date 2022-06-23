import 'package:flutter/material.dart';
import 'package:storystains/common/utils/utils.dart';

class PositionEdit extends StatelessWidget {
  final ValueNotifier<int> positionController;

  const PositionEdit({Key? key, required this.positionController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      builder: (context, value, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
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
                min: 0.0,
                max: 100.0,
                label: '${value.round()}',
                onChanged: (newValue) {
                  positionController.value = newValue.floor();
                },
              ),
            ),
          ],
        );
      },
      valueListenable: positionController,
    );
  }
}
