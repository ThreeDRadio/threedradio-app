import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:player/audio/audio_start_params.dart';
import 'package:player/environment/environment.dart';

final liveMediaControlsPlaying = [
  MediaControl.pause,
  MediaControl.stop,
];
final liveMediaControlsPaused = [
  MediaControl.play,
  MediaControl.stop,
];

final onDemandMediaControlsPaused = [
  MediaControl.play,
  MediaControl.stop,
  MediaControl.fastForward,
  MediaControl.rewind,
];
final onDemandMediaControlsPlaying = [
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
  PlaybackMode? mode;

  List<MediaControl> get currentMediaControls {
    if (mode == PlaybackMode.live) {
      if (_player.playing) {
        return liveMediaControlsPlaying;
      } else {
        return liveMediaControlsPaused;
      }
    } else {
      if (_player.playing) {
        return onDemandMediaControlsPlaying;
      } else {
        return onDemandMediaControlsPaused;
      }
    }
  }

  ThreeDBackgroundTask() {
    _player.durationStream.listen((duration) {
      if (AudioServiceBackground.mediaItem != null) {
        AudioServiceBackground.setMediaItem(
            AudioServiceBackground.mediaItem!.copyWith(duration: duration));
      }
    });

    _player.positionStream.listen((event) {
      AudioServiceBackground.setState(
        controls: currentMediaControls,
        processingState: AudioProcessingState.ready,
        playing: _player.playing,
        position: event,
      );
    });
  }

  Future<void> onPlayMediaItem(MediaItem mediaItem) async {
    mode = mediaItem.id == Environment.liveStreamUrl
        ? PlaybackMode.live
        : PlaybackMode.onDemand;

    await AudioServiceBackground.setMediaItem(mediaItem);

    await AudioServiceBackground.setState(
      playing: false,
      controls: currentMediaControls,
      processingState: AudioProcessingState.buffering,
    );
    // Show the media notification, and let all clients no what
    // playback state and media item to display.
    if (mode == PlaybackMode.live) {
      await _player.setUrl(mediaItem.id);
    } else {
      // we use the caching audio source in on-demand mode
      // to improve network performance
      await _player
          .setAudioSource(LockCachingAudioSource(Uri.parse(mediaItem.id)));
    }
    _player.play();
    await AudioServiceBackground.setState(
      playing: true,
      controls: currentMediaControls,
      processingState: AudioProcessingState.ready,
    );

    super.onPlayMediaItem(mediaItem);
  }

  @override
  Future<void> onUpdateMediaItem(MediaItem mediaItem) {
    AudioServiceBackground.setMediaItem(mediaItem);
    return super.onUpdateMediaItem(mediaItem);
  }

  @override
  Future<void> onSeekTo(Duration position) {
    if (_player.playing && mode == PlaybackMode.onDemand) {
      _player.seek(position);
    }
    return super.onSeekTo(position);
  }

  @override
  Future<void> onStop() async {
    await _player.stop();
    await _player.dispose();
    await AudioServiceBackground.setState(
      controls: [],
      processingState: AudioProcessingState.stopped,
      playing: false,
    );
    await super.onStop();
  }

  @override
  Future<void> onPause() async {
    await _player.pause();
    await AudioServiceBackground.setState(
        controls: currentMediaControls,
        playing: false,
        processingState: AudioProcessingState.ready);
    return super.onPause();
  }

  Future<void> onPlay() async {
    await _player.play();
    await AudioServiceBackground.setState(
        controls: currentMediaControls,
        playing: true,
        processingState: AudioProcessingState.ready);
    super.onPlay();
  }
}
