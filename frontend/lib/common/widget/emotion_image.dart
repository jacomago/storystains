import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:storystains/common/constant/app_config.dart';
import 'package:storystains/model/entity/emotion.dart';

class EmotionImage extends StatelessWidget {
  const EmotionImage({
    Key? key,
    required this.emotion,
  }) : super(key: key);
  final Emotion emotion;
  @override
  Widget build(BuildContext context) {
    return SvgPicture.network(
      '${AppConfig.imagesBaseUrl}${emotion.iconUrl}',
    );
  }
}
