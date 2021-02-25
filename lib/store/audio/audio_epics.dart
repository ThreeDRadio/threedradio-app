import 'package:audio_service/audio_service.dart';
import 'package:player/audio/audio_start_params.dart';
import 'package:player/audio/background_task.dart';
import 'package:player/environment/environment.dart';
import 'package:player/services/wp_schedule_api.dart';
import 'package:player/store/app_state.dart';
import 'package:player/store/audio/app_actions.dart';
import 'package:player/store/audio/audio_actions.dart';
import 'package:player/store/schedules/schedules_selectors.dart';
import 'package:redux_epics/redux_epics.dart';
import 'package:rxdart/rxdart.dart';

class AudioEpics extends EpicClass<AppState> {
  AudioEpics() {
    _epic = combineEpics([
      _audioStateChanges,
      _mediaItemChange,
      _playEpisode,
      _playLiveStream,
      _pause,
      _resume,
      _seekToPosition,
      _stop,
    ]);
  }

  Epic<AppState> _epic;
  Stream call(Stream actions, EpicStore<AppState> store) {
    return _epic(actions, store);
  }

  Stream _pause(Stream actions, EpicStore<AppState> store) {
    return actions.whereType<RequestPause>().asyncMap((event) async {
      await AudioService.pause();
      return SuccessPause();
    });
  }

  Stream _resume(Stream actions, EpicStore<AppState> store) {
    return actions.whereType<RequestResume>().asyncMap((event) async {
      await AudioService.play();
      return SuccessResume();
    });
  }

  Stream _stop(Stream actions, EpicStore<AppState> store) {
    return actions.whereType<RequestStop>().asyncMap((event) async {
      await AudioService.stop();
      return SuccessStop();
    });
  }

  Stream _playEpisode(Stream actions, EpicStore<AppState> store) {
    return actions
        .whereType<RequestPlayEpisode>()
        .asyncMap((RequestPlayEpisode action) async {
      final currentShowId = getCurrentShowId(store.state);
      final program =
          store.state.onDemandPrograms.entities[action.episode.showId];
      final show = store.state.shows.entities.values.firstWhere(
          (element) => element.onDemandShowId == action.episode.showId);

      if (!AudioService.running) {
        await AudioService.start(
          backgroundTaskEntrypoint: backgroundTaskEntrypoint,
          androidNotificationIcon: 'drawable/ic_threedradio',
          params: AudioStartParams(
            mode: PlaybackMode.onDemand,
            url: action.episode.url,
          ).toJson(),
        );
      }
      await AudioService.playMediaItem(
        MediaItem(
          title: show?.title?.text ?? 'Three D Radio',
          artUri: show?.thumbnail is String ? show?.thumbnail : null,
          album: action.episode.date,
          extras: {'episode': action.episode.id, 'showId': show.id},
          id: action.episode.url,
        ),
      );
      return SuccessPlayEpisode();
    });
  }

  Stream _playLiveStream(Stream actions, EpicStore<AppState> store) {
    return actions.whereType<RequestPlayLive>().asyncMap((event) async {
      final currentShowId = getCurrentShowId(store.state);
      Show currentShow;
      if (currentShowId != null) {
        currentShow = store.state.shows.entities[currentShowId];
      }
      if (!AudioService.running) {
        await AudioService.start(
          backgroundTaskEntrypoint: backgroundTaskEntrypoint,
          androidNotificationIcon: 'drawable/ic_threedradio',
        );
      }
      await AudioService.playMediaItem(
        MediaItem(
          title: currentShow?.title?.text ?? 'Three D Radio',
          artUri:
              currentShow?.thumbnail is String ? currentShow?.thumbnail : null,
          album: 'Three D Radio - Live',
          extras: {
            'showId': currentShow?.id,
          },
          id: Environment.liveStreamUrl,
        ),
      );
      return SuccessPlayLive();
    });
  }

  Stream _audioStateChanges(Stream actions, EpicStore<AppState> store) {
    return actions.whereType<AppStartAction>().switchMap((_) => AudioService
        .playbackStateStream
        .where((event) => event != null)
        .throttleTime(const Duration(milliseconds: 100), trailing: true)
        .map((event) => AudioStateChange(state: event)));
  }

  Stream _mediaItemChange(Stream actions, EpicStore<AppState> store) {
    return actions.whereType<AppStartAction>().switchMap((_) => AudioService
        .currentMediaItemStream
        .map((event) => MediaItemChange(item: event)));
    // .debounceTime(const Duration(seconds: 1)));
  }

  Stream _seekToPosition(Stream actions, EpicStore<AppState> store) {
    return actions.whereType<RequestSeek>().asyncMap((action) async {
      await AudioService.seekTo(action.position);
      return SuccessSeek();
    });
  }
}
