import 'package:audio_service/audio_service.dart';
import 'package:json_annotation/json_annotation.dart';

part 'audio_start_params.g.dart';

enum PlaybackMode {
  live,
  onDemand,
}

Map<String, dynamic> mediaItemToJson(MediaItem? item) {
  if (item == null) {
    return {};
  }
  return <String, dynamic>{
    'id': item.id,
    'title': item.title,
  };
}

MediaItem mediaItemFromJson(Map<String, dynamic> json) {
  return MediaItem(
    id: json['id'],
    title: json['title'],
  );
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

  @JsonKey(toJson: mediaItemToJson, fromJson: mediaItemFromJson)
  final MediaItem? item;

  factory AudioStartParams.fromJson(Map<String, dynamic> json) =>
      _$AudioStartParamsFromJson(json);
  Map<String, dynamic> toJson() => _$AudioStartParamsToJson(this);
}
