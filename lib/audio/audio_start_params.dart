import 'package:json_annotation/json_annotation.dart';

part 'audio_start_params.g.dart';

enum PlaybackMode {
  live,
  onDemand,
}

@JsonSerializable()
class AudioStartParams {
  AudioStartParams({
    this.mode,
    this.url,
    this.title,
  });

  final PlaybackMode mode;
  final String url;
  final String title;

  factory AudioStartParams.fromJson(Map<String, dynamic> json) =>
      _$AudioStartParamsFromJson(json);
  Map<String, dynamic> toJson() => _$AudioStartParamsToJson(this);
}
