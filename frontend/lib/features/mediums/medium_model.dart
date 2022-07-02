import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'medium_model.g.dart';

@JsonSerializable()
class Medium {
  String name;

  Medium({
    required this.name,
  });

  factory Medium.fromJson(Map<String, dynamic> json) => _$MediumFromJson(json);

  Map<String, dynamic> toJson() => _$MediumToJson(this);

  @override
  String toString() {
    return json.encode(toJson());
  }

  @override
  bool operator ==(Object other) {
    return other is Medium && name == other.name;
  }

  @override
  int get hashCode => name.hashCode;
}

@JsonSerializable()
class MediumsResp {
  List<Medium> mediums;

  MediumsResp({required this.mediums});

  factory MediumsResp.fromJson(Map<String, dynamic> json) =>
      _$MediumsRespFromJson(json);

  Map<String, dynamic> toJson() => _$MediumsRespToJson(this);
}
