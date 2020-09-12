import 'package:audio_service/audio_service.dart';

class AudioState {
  const AudioState({
    this.state,
    this.currentItem,
  });

  final PlaybackState state;
  final MediaItem currentItem;

  AudioState copyWith({
    PlaybackState state,
    MediaItem currentItem,
  }) {
    return AudioState(
      currentItem: currentItem ?? this.currentItem,
      state: state ?? this.state,
    );
  }

  Map<String, dynamic> toJson() => {
        'currentItem': currentItem?.toJson(),
        if (state != null)
          'state': {
            'currentPosition': state.currentPosition.toString(),
            'processingState': state.processingState.toString(),
            'playing': state.playing,
          },
      };
}
