import 'package:player/store/app_state.dart';
import 'package:player/store/audio/audio_actions.dart';
import 'package:player/store/history/history_item.dart';
import 'package:redux_entity/redux_entity.dart';
import 'package:redux_epics/redux_epics.dart';
import 'package:rxdart/rxdart.dart';

class HistoryEpics extends EpicClass<AppState> {
  HistoryEpics() {
    _epic = combineEpics([_saveHistory]);
  }
  late Epic<AppState> _epic;

  Stream<dynamic> call(Stream<dynamic> actions, EpicStore<AppState> store) {
    return _epic(actions, store);
  }

  Stream<dynamic> _saveHistory(
      Stream<dynamic> actions, EpicStore<AppState> store) {
    return actions
        .whereType<AudioStateChange>()
        .where((action) => action.state?.playing ?? false)
        .where((action) => store.state.audio.currentItem?.duration != null)
        .throttleTime(const Duration(seconds: 1))
        .map((action) {
      return UpdateOne<HistoryItem>(
        HistoryItem(
          episodeDate: store.state.audio.currentItem!.album,
          id: store.state.audio.currentItem!.id,
          position: action.state!.currentPosition,
          showLength: store.state.audio.currentItem!.duration!,
          showId: store.state.audio.currentItem!.extras!['showId'].toString(),
        ),
      );
    });
  }
}
