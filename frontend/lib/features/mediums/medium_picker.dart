import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../common/utils/utils.dart';
import 'medium.dart';

/// Widget for picking a [Medium]
class MediumPicker extends StatelessWidget {
  /// Widget for picking a [Medium]
  const MediumPicker({
    super.key,
    required this.mediumController,
    required this.onChanged,
  });

  /// controller of  [Medium]
  final ValueNotifier<Medium?> mediumController;

  /// callback for on changed
  final ValueChanged<Medium?> onChanged;
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<Medium?>(
        valueListenable: mediumController,
        builder: (context, v, _) => DropdownButton<Medium?>(
          style: context.titleMedium,
          value: v,
          onChanged: (newValue) {
            if (newValue != null) {
              mediumController.value = newValue;
              onChanged(newValue);
            }
          },
          items: Provider.of<MediumsState>(context)
              .items
              .map((e) => DropdownMenuItem<Medium?>(
                    value: e,
                    child: Text(
                      e.name,
                      style: context.bodyMedium,
                    ),
                  ))
              .toList(),
        ),
      );
}
