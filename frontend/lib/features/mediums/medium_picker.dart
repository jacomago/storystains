import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storystains/common/utils/utils.dart';
import 'package:storystains/features/mediums/medium.dart';

class MediumPicker extends StatelessWidget {
  const MediumPicker({
    Key? key,
    required this.mediumController,
  }) : super(key: key);
  final ValueNotifier<Medium> mediumController;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Medium>(
      valueListenable: mediumController,
      builder: (context, v, _) {
        return DropdownButton<Medium>(
          style: context.titleMedium,
          value: v,
          onChanged: (Medium? newValue) {
            if (newValue != null) {
              mediumController.value = newValue;
            }
          },
          items: Provider.of<MediumsState>(context).items.map((e) {
            return DropdownMenuItem<Medium>(
              value: e,
              child: Text(
                e.name,
                style: context.bodyMedium,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
