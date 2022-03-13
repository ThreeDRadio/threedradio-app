import 'package:audio_service/audio_service.dart';
import 'package:player/audio/audio_start_params.dart';

class AudioState {
  const AudioState({
    this.state,
    this.currentItem,
  });

  final PlaybackState? state;
  final MediaItem? currentItem;

  AudioState copyWith({
    PlaybackState? state,
    MediaItem? currentItem,
  }) {
    return AudioState(
      currentItem: currentItem ?? this.currentItem,
      state: state ?? this.state,
    );
  }

  Map<String, dynamic> toJson() => {
        'currentItem': mediaItemToJson(currentItem),
        if (state != null)
          'state': {
            'currentPosition': state?.position.toString(),
            'processingState': state?.processingState.toString(),
            'playing': state?.playing,
          },
      };
}
