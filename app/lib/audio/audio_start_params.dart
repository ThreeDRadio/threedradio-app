import 'package:audio_service/audio_service.dart';
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
    this.item,
  });

  final PlaybackMode? mode;
  final String? url;
  final MediaItem? item;

  factory AudioStartParams.fromJson(Map<String, dynamic> json) =>
      _$AudioStartParamsFromJson(json);
  Map<String, dynamic> toJson() => _$AudioStartParamsToJson(this);
}
