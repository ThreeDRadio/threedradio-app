import 'package:audio_service/audio_service.dart';
import 'package:player/audio/audio_start_params.dart';
import 'package:player/services/on_demand_api.dart';

class RequestPlayLive {}

class SuccessPlayLive {}

class FailPlayLive {}

class RequestPause {}

class SuccessPause {}

class RequestResume {}

class SuccessResume {}

class RequestStop {}

class SuccessStop {}

class RequestSeek {
  const RequestSeek(this.position);
  final Duration position;
  Map<String, dynamic> toJson() => {
        'position': position.toString(),
      };
}

class SuccessSeek {}

class RequestPlayEpisode {
  const RequestPlayEpisode({
    required this.episode,
    this.position,
  });
  final OnDemandEpisode episode;
  final Duration? position;
}

class SuccessPlayEpisode {}

class AudioStateChange {
  AudioStateChange({this.state});
  PlaybackState? state;

  Map<String, dynamic> toJson() => {
        'object': state == null ? 'null' : 'exists',
        'currentPosition': state?.position.toString(),
        'processingState': state?.processingState.toString(),
        'playing': state?.playing,
      };
}

class MediaItemChange {
  MediaItemChange({this.item});
  final MediaItem? item;
  Map<String, dynamic> toJson() => {
        'item': mediaItemToJson(item),
      };
}
