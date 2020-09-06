import 'package:player/providers/schedule_provider.dart';
import 'package:player/providers/shows_provider.dart';
import 'package:player/services/wp_schedule_api.dart';
import 'package:rxdart/rxdart.dart';

class CurrentShowStream {
  CurrentShowStream({
    this.shows,
    this.schedules,
  }) {
    currentShow = Stream.periodic(const Duration(seconds: 1))
        .switchMap(
          (value) => Stream.fromFuture(
            schedules.getCurrentShowId(),
          ),
        )
        .switchMap(
          (value) => Stream.fromFuture(
            shows.getShow(value),
          ),
        )
        .distinct((s1, s2) => s1.id == s2.id);
  }
  final ShowsProvider shows;
  final ScheduleProvider schedules;
  Stream<Show> currentShow;
}
