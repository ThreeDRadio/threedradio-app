import 'package:player/services/wp_schedule_api.dart';
import 'package:redux_entity/redux_entity.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:player/store/app_state.dart';

const scheduleSlugs = {
  1: 'monday',
  2: 'tuesday',
  3: 'wednesday',
  4: 'thursday',
  5: 'friday',
  6: 'saturday',
  7: 'sunday',
};

RemoteEntityState<Schedule> getScheduleState(AppState state) {
  return state.schedules;
}

Schedule? getToday(AppState state) {
  final today = DateTime.now().weekday;
  try {
    return getScheduleState(state).entities.values.firstWhere(
          (element) => element.slug == scheduleSlugs[today],
        );
  } catch (err) {
    return null;
  }
}

String? getCurrentShowId(AppState state) {
  var adl = tz.getLocation('Australia/Adelaide');
  var now = tz.TZDateTime.now(adl);

  final schedule = getToday(state);

  try {
    final currentShow = schedule?.shows.firstWhere((show) {
      final start = show.show_time.split(':');
      final end = show.show_time_end.split(':');

      final startTime = tz.TZDateTime(adl, now.year, now.month, now.day,
          int.parse(start[0]), int.parse(start[1]));
      final endTime = tz.TZDateTime(adl, now.year, now.month, now.day,
          int.parse(end[0]), int.parse(end[1]));

      return now.isBefore(endTime) && now.isAfter(startTime);
    });
    return currentShow?.show_id.first.trim();
  } catch (err) {
    return null;
  }
}
