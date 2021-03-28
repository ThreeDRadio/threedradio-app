import 'package:audio_service/audio_service.dart';
import 'package:player/services/on_demand_api.dart';

class RequestPlayLive {}

class SuccessPlayLive {}

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
  const RequestPlayEpisode({required this.episode});
  final OnDemandEpisode episode;
}

class SuccessPlayEpisode {}

class AudioStateChange {
  AudioStateChange({this.state});
  PlaybackState? state;

  Map<String, dynamic> toJson() => {
        'object': state == null ? 'null' : 'exists',
        'currentPosition': state?.currentPosition.toString(),
        'processingState': state?.processingState.toString(),
        'playing': state?.playing,
      };
}

class MediaItemChange {
  MediaItemChange({this.item});
  final MediaItem? item;
  Map<String, dynamic> toJson() => {
        'item': item?.toJson(),
      };
}
