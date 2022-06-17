import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:storystains/common/constant/app_config.dart';
import 'package:storystains/model/entity/emotion.dart';

class EmotionImage extends StatelessWidget {
  const EmotionImage({
    Key? key,
    required this.emotion,
    this.width,
    this.height,
  }) : super(key: key);
  final Emotion emotion;
  final double? width;
  final double? height;
  @override
  Widget build(BuildContext context) {
    return SvgPicture.network(
      '${AppConfig.imagesBaseUrl}${emotion.iconUrl}',
      width: width,
      height: height,
    );
  }
}
