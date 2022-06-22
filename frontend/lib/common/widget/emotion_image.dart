import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:storystains/common/utils/utils.dart';
import 'package:storystains/features/emotions/emotion_state.dart';
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
      EmotionsState.iconFullUrl(emotion),
      width: width,
      height: height,
      color: context.colors.onPrimaryContainer,
    );
  }
}
