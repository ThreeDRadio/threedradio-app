import 'package:player/services/wp_schedule_api.dart';
import 'package:player/store/app_state.dart';
import 'package:redux_entity/redux_entity.dart';
import 'package:redux_epics/redux_epics.dart';

class SchedulesEpics extends EpicClass<AppState> {
  SchedulesEpics({required this.api});

  final WpScheduleApiService api;

  Stream<dynamic> call(
      Stream<dynamic> actions, EpicStore<AppState> store) async* {
    await for (final action in actions) {
      if (action is RequestRetrieveAll<Schedule>) {
        final now = DateTime.now();
        if (action.forceRefresh ||
            store.state.schedules.lastFetchAllTime == null ||
            now.difference(store.state.schedules.lastFetchAllTime!).inHours >
                2) {
          final schedules = await api.getSchedules();
          yield SuccessRetrieveAll<Schedule>(schedules);
        } else {
          yield SuccessRetrieveAllFromCache<Schedule>(
              store.state.schedules.entities.values.toList());
        }
      }
    }
  }
}
