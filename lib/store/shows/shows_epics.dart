import 'package:player/services/wp_schedule_api.dart';
import 'package:player/store/app_state.dart';
import 'package:redux_entity/redux_entity.dart';
import 'package:redux_epics/redux_epics.dart';

class ShowsEpics extends EpicClass<AppState> {
  ShowsEpics({
    required this.api,
  }) {
    _epic = combineEpics([
      _getShows,
    ]);
  }

  final WpScheduleApiService api;
  late Epic<AppState> _epic;

  Stream<dynamic> call(Stream<dynamic> actions, EpicStore<AppState> store) {
    return _epic(actions, store);
  }

  Stream<dynamic> _getShows(
      Stream<dynamic> actions, EpicStore<AppState> store) async* {
    await for (final action in actions) {
      if (action is RequestRetrieveAll<Show>) {
        final now = DateTime.now();
        if (store.state.shows.lastFetchAllTime == null ||
            now.difference(store.state.shows.lastFetchAllTime!).inHours > 2) {
          try {
            final shows = await api.getShows();
            yield SuccessRetrieveAll<Show>(shows);
          } catch (err) {
            yield FailRetrieveAll<Show>(err);
          }
        } else {
          yield SuccessRetrieveAllFromCache<Show>(
              store.state.shows.entities.values.toList());
        }
      }
    }
  }
}
