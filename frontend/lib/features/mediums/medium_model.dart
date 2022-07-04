import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medium_model.g.dart';

@JsonSerializable()
@immutable

/// Medium of the story, i.e. Book, Film, etc
class Medium {
  /// Name of the Medium
  final String name;

  /// Medium of the story, i.e. Book, Film, etc
  const Medium({
    required this.name,
  });

  /// Medium from Json
  factory Medium.fromJson(Map<String, dynamic> json) => _$MediumFromJson(json);

  /// Medium to Json
  Map<String, dynamic> toJson() => _$MediumToJson(this);

  @override
  String toString() => json.encode(toJson());

  @override
  bool operator ==(Object other) => other is Medium && name == other.name;

  @override
  int get hashCode => name.hashCode;

  /// Default Medium
  static Medium mediumDefault = const Medium(name: 'Book');
}

/// Response from Api of list of Mediums
@JsonSerializable()
class MediumsResp {
  /// List of the Mediums
  List<Medium> mediums;

  /// Response from Api of list of Mediums
  MediumsResp({required this.mediums});

  /// List of Mediums from Json
  factory MediumsResp.fromJson(Map<String, dynamic> json) =>
      _$MediumsRespFromJson(json);

  /// List of Mediums to Json
  Map<String, dynamic> toJson() => _$MediumsRespToJson(this);
}
