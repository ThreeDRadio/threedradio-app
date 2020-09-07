import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:player/audio/audio_start_params.dart';

final liveMediaControls = [
  MediaControl.play,
  MediaControl.pause,
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

  AudioStartParams params;

  Future<void> onStart(Map<String, dynamic> params) async {
    this.params = AudioStartParams.fromJson(params);
  }

  onPlay() async {
    _player.setUrl(params.url);
    _player.play();
    // Show the media notification, and let all clients no what
    // playback state and media item to display.
    await AudioServiceBackground.setState(
        playing: true,
        controls: params.mode == PlaybackMode.live
            ? liveMediaControls
            : onDemandMediaControls,
        processingState: AudioProcessingState.ready);
    await AudioServiceBackground.setMediaItem(MediaItem(
      title: "Hey Jude",
    ));
  }
}
