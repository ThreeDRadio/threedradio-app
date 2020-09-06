import 'package:player/services/wp_schedule_api.dart';
import 'package:timezone/timezone.dart' as tz;

const _scheduleSlugs = {
  1: 'monday',
  2: 'tuesday',
  3: 'wednesday',
  4: 'thursday',
  5: 'friday',
  6: 'saturday',
  7: 'sunday',
};

class ScheduleProvider {
  ScheduleProvider({
    this.api,
  });

  final WpScheduleApiService api;

  DateTime lastFetch;
  List<Schedule> schedules;

  Future<void> refreshSchedules() async {
    schedules = await api.getSchedules();
    this.lastFetch = DateTime.now();
  }

  Future<Schedule> getToday() async {
    if (schedules == null || needsRefresh) {
      await refreshSchedules();
    }
    final today = DateTime.now().weekday;
    return schedules
        .firstWhere((element) => element.slug == _scheduleSlugs[today]);
  }

  Future<int> getCurrentShowId() async {
    var adl = tz.getLocation('Australia/Adelaide');
    var now = tz.TZDateTime.now(adl);

    final schedule = await getToday();

    final currentShow = schedule.shows.firstWhere((show) {
      final start = show.show_time.split(':');
      final end = show.show_time_end.split(':');

      final startTime = tz.TZDateTime(adl, now.year, now.month, now.day,
          int.parse(start[0]), int.parse(start[1]));
      final endTime = tz.TZDateTime(adl, now.year, now.month, now.day,
          int.parse(end[0]), int.parse(end[1]));

      return now.isBefore(endTime) && now.isAfter(startTime);
    }, orElse: () => null);

    return int.parse(currentShow?.show_id?.first);
  }

  bool get needsRefresh =>
      lastFetch == null || DateTime.now().difference(lastFetch).inHours > 23;
}
