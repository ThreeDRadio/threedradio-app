import 'package:player/services/wp_schedule_api.dart';
import 'package:player/store/app_state.dart';
import 'package:redux_entity/redux_entity.dart';
import 'package:redux_epics/redux_epics.dart';

class ShowsEpics extends EpicClass<AppState> {
  ShowsEpics({this.api});

  final WpScheduleApiService api;

  Stream<dynamic> call(
      Stream<dynamic> actions, EpicStore<AppState> store) async* {
    await for (final action in actions) {
      if (action is RequestRetrieveAll<Show>) {
        final now = DateTime.now();
        if (store.state.shows.lastFetchAllTime == null ||
            now.difference(store.state.shows.lastFetchAllTime).inHours > 2) {
          final shows = await api.getShows();
          yield SuccessRetrieveAll<Show>(shows);
        } else {
          yield SuccessRetrieveAllFromCache<Show>(
              store.state.shows.entities.values.toList());
        }
      }
    }
  }
}
