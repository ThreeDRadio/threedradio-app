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

/// Returns the week of the month for the [date].
///
/// Number will be between 1-5 (inclusive)
///
/// This implementation is copied from the OnAir2 theme
/// so that the app shows the same thing as the website.
///
/// See /onair2/functions.php:989
///
/// Defaults to the current time if [date] is not provided.
///
int weekOfMonth({DateTime? date}) {
  date ??= DateTime.now();
  return (date.day / 7).ceil();
}

Schedule? getToday(AppState state) {
  final today = DateTime.now().weekday;
  final week = weekOfMonth();

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
