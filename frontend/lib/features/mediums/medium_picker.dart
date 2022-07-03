import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storystains/common/utils/utils.dart';
import 'package:storystains/features/mediums/medium.dart';

class MediumPicker extends StatelessWidget {
  const MediumPicker({
    Key? key,
    required this.mediumController,
  }) : super(key: key);
  final ValueNotifier mediumController;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MediumsState(MediumsService()),
      child: DropdownButton<Medium>(
        style: context.titleMedium,
        value: mediumController.value,
        onChanged: (Medium? newValue) {
          mediumController.value = newValue!;
        },
        items: Provider.of<MediumsState>(context)
            .items
            .map(
              (e) => DropdownMenuItem<Medium>(
                value: e,
                child: Text(
                  e.name,
                  style: context.bodyMedium,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
