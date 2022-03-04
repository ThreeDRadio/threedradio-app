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

/// Returns the week number for the date, in the range (1,2).
int weekNumber({DateTime? date}) {
  date ??= DateTime.now();

  // Unix Epoch was Thursday, January 1, 1970
  // we are treating the start of the first full week
  // since epoch as week 0
  // This hard coded timestamp is
  // Mon Jan 05 1970 00:00:00 GMT+0930 (Australian Central Standard Time)
  const threeDEpoch = 311400;

  // so we are subtracting this epoch from the current time, and then
  // converting to weeks
  final elapsedSeconds = (date.millisecondsSinceEpoch / 1000) - threeDEpoch;
  final weekNumber = elapsedSeconds / 60 / 60 / 24 / 7;

  // finally, we modulus with 2 then add 1 to get a number in the range (1, 2)
  // which is what the wordpress schedule requires
  return (weekNumber.toInt() % 2) + 1;
}

Schedule? getToday(AppState state) {
  return getScheduleForDate(state, DateTime.now());
}

Schedule? getScheduleForDate(AppState state, DateTime date) {
  final today = date.weekday;
  final week = weekNumber(date: date);

  final suffix = (week % 2 == 0) ? '-b' : '-a';
  try {
    return getScheduleState(state).entities.values.firstWhere(
          (element) => element.slug == (scheduleSlugs[today]! + suffix),
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
