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

class ThreeDBackgroundTask extends BaseAudioHandler with SeekHandler {
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
      if (mediaItem.valueWrapper != null) {
        mediaItem.add(
          mediaItem.valueWrapper?.value!.copyWith(duration: duration),
        );
      }
    });

    _player.positionStream.where(((event) => _player.playing)).listen((event) {
      playbackState.add(PlaybackState(
        processingState: AudioProcessingState.ready,
        controls: currentMediaControls,
        playing: _player.playing,
        updatePosition: event,
      ));
    });
    playbackState.add(
      PlaybackState(
        controls: [],
        playing: false,
        processingState: AudioProcessingState.idle,
      ),
    );
  }

  @override
  Future<void> playMediaItem(MediaItem item) async {
    mode = item.id == Environment.liveStreamUrl
        ? PlaybackMode.live
        : PlaybackMode.onDemand;

    mediaItem.add(item);

    playbackState.add(PlaybackState(
      playing: false,
      controls: currentMediaControls,
      processingState: AudioProcessingState.buffering,
    ));

    // Show the media notification, and let all clients no what
    // playback state and media item to display.
    if (mode == PlaybackMode.live) {
      await _player.setUrl(item.id);
    } else {
      // we use the caching audio source in on-demand mode
      // to improve network performance
      await _player.setAudioSource(LockCachingAudioSource(Uri.parse(item.id)));
    }
    _player.play();
    playbackState.add(PlaybackState(
      playing: true,
      controls: currentMediaControls,
      processingState: AudioProcessingState.ready,
    ));

    super.playMediaItem(item);
  }

  @override
  Future<void> updateMediaItem(MediaItem item) {
    mediaItem.add(item);
    return super.updateMediaItem(item);
  }

  @override
  Future<void> seek(Duration position) {
    if (_player.playing && mode == PlaybackMode.onDemand) {
      _player.seek(position);
    }
    return super.seek(position);
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    //await _player.dispose();
    playbackState.add(PlaybackState(
      controls: [],
      processingState: AudioProcessingState.ready,
      playing: false,
    ));
    await super.stop();
  }

  @override
  Future<void> pause() async {
    await _player.pause();
    playbackState.add(
      PlaybackState(
        controls: currentMediaControls,
        playing: false,
        processingState: AudioProcessingState.ready,
      ),
    );
    return super.pause();
  }

  Future<void> play() async {
    await _player.play();
    playbackState.add(
      PlaybackState(
        controls: currentMediaControls,
        playing: true,
        processingState: AudioProcessingState.ready,
      ),
    );
    super.play();
  }
}
