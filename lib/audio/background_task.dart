import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:player/audio/audio_start_params.dart';

final liveMediaControlsPlaying = [
  MediaControl.pause,
  MediaControl.stop,
];
final liveMediaControlsPaused = [
  MediaControl.play,
  MediaControl.stop,
];

final onDemandMediaControls = [
  MediaControl.play,
  MediaControl.pause,
  MediaControl.stop,
  MediaControl.fastForward,
  MediaControl.rewind,
];

backgroundTaskEntrypoint() {
  AudioServiceBackground.run(() => ThreeDBackgroundTask());
}

class ThreeDBackgroundTask extends BackgroundAudioTask {
  AudioPlayer _player = AudioPlayer();

  ThreeDBackgroundTask() {
    _player.durationStream.listen((duration) {
      AudioServiceBackground.setMediaItem(
          AudioServiceBackground.mediaItem.copyWith(duration: duration));
    });

    _player.positionStream.listen((event) {
      AudioServiceBackground.setState(
        controls: params?.mode == PlaybackMode.live
            ? liveMediaControlsPlaying
            : onDemandMediaControls,
        processingState: AudioProcessingState.ready,
        playing: _player.playing,
        position: event,
      );
    });
  }

  AudioStartParams params;
  MediaItem currentItem;

  Future<void> onStart(Map<String, dynamic> params) async {
    this.params = AudioStartParams.fromJson(params);
  }

  Future<void> onPlay() async {
    await _player.setUrl(params.url);
    _player.play();
    // Show the media notification, and let all clients no what
    // playback state and media item to display.
    await AudioServiceBackground.setState(
      playing: true,
      controls: params.mode == PlaybackMode.live
          ? liveMediaControlsPlaying
          : onDemandMediaControls,
      processingState: AudioProcessingState.ready,
    );
  }

  @override
  Future<void> onUpdateMediaItem(MediaItem mediaItem) {
    AudioServiceBackground.setMediaItem(mediaItem);
    return super.onUpdateMediaItem(mediaItem);
  }

  @override
  Future<void> onSeekTo(Duration position) {
    if (_player.playing && params.mode == PlaybackMode.onDemand) {
      _player.seek(position);
    }
    return super.onSeekTo(position);
  }

  @override
  Future<void> onStop() async {
    await _player.stop();
    await AudioServiceBackground.setState(
      controls: [],
      processingState: AudioProcessingState.stopped,
      playing: false,
    );
    await super.onStop();
  }

  @override
  Future<void> onPause() async {
    _player.pause();
    await AudioServiceBackground.setState(
        controls: params.mode == PlaybackMode.live
            ? liveMediaControlsPaused
            : onDemandMediaControls,
        playing: false,
        processingState: AudioProcessingState.ready);
    return super.onPause();
  }
}
