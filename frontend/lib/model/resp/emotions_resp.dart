import 'package:json_annotation/json_annotation.dart';

import '../entity/emotion.dart';

part 'emotions_resp.g.dart';

@JsonSerializable()
class EmotionsResp {
  List<Emotion> emotions;

  EmotionsResp({required this.emotions});

  factory EmotionsResp.fromJson(Map<String, dynamic> json) =>
      _$EmotionsRespFromJson(json);

  Map<String, dynamic> toJson() => _$EmotionsRespToJson(this);
}
