// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';

part 'show_response.dto.g.dart';

@JsonSerializable()
class MinimalShowDto {
  const MinimalShowDto({
    required this.term_id,
    required this.title,
    required this.slug,
    required this.link,
    required this.start_time,
    required this.end_time,
    required this.presenter,
    required this.day,
    required this.weekOption,
  });
  factory MinimalShowDto.fromJson(Map<String, dynamic> json) =>
      _$MinimalShowDtoFromJson(json);
  Map<String, dynamic> toJson() => _$MinimalShowDtoToJson(this);

  final String term_id;
  final String title;
  final String slug;
  final String link;
  final String start_time;
  final String end_time;
  final String presenter;
  final String day;
  final String weekOption;
}

@JsonSerializable()
class ShowResponseDto {
  const ShowResponseDto({
    required this.success,
    required this.cached,
    required this.show,
    this.message,
  });

  factory ShowResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ShowResponseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ShowResponseDtoToJson(this);

  final bool success;
  final bool cached;
  final MinimalShowDto show;
  final String? message;
}
