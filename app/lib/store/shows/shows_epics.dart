import 'package:flutter/foundation.dart';
import 'package:player/services/new_api/dto/show_dto.dart';
import 'package:player/services/new_api/schedule_api.dart';
import 'package:player/store/app_state.dart';
import 'package:redux_entity/redux_entity.dart';
import 'package:redux_epics/redux_epics.dart';

class ShowsEpics extends EpicClass<AppState> {
  ShowsEpics({required this.api}) {
    _epic = combineEpics([_getShows]);
  }

  final NewScheduleApi api;
  late Epic<AppState> _epic;

  @override
  Stream<dynamic> call(Stream<dynamic> actions, EpicStore<AppState> store) {
    return _epic(actions, store);
  }

  Stream<dynamic> _getShows(
    Stream<dynamic> actions,
    EpicStore<AppState> store,
  ) async* {
    await for (final action in actions) {
      if (action is RequestRetrieveAll<ShowDto>) {
        final now = DateTime.now();
        if (action.forceRefresh ||
            store.state.shows.lastFetchAllTime == null ||
            now.difference(store.state.shows.lastFetchAllTime!).inMinutes >
                30) {
          try {
            final shows = await api.getAllPrograms();
            yield SuccessRetrieveAll<ShowDto>(shows);
          } catch (err, st) {
            debugPrint(err.toString());
            yield FailRetrieveAll<ShowDto>(err);
          }
        } else {
          yield SuccessRetrieveAllFromCache<ShowDto>(
            store.state.shows.entities.values.toList(),
          );
        }
      }
    }
  }
}
