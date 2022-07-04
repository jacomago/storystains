import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../common/utils/utils.dart';
import 'medium.dart';

class MediumPicker extends StatelessWidget {
  const MediumPicker({
    Key? key,
    required this.mediumController,
  }) : super(key: key);
  final ValueNotifier<Medium> mediumController;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<Medium>(
        valueListenable: mediumController,
        builder: (context, v, _) => DropdownButton<Medium>(
          style: context.titleMedium,
          value: v,
          onChanged: (newValue) {
            if (newValue != null) {
              mediumController.value = newValue;
            }
          },
          items: Provider.of<MediumsState>(context)
              .items
              .map((e) => DropdownMenuItem<Medium>(
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
