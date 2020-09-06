import 'package:player/services/wp_schedule_api.dart';

class ShowsProvider {
  ShowsProvider({
    this.api,
  });

  final WpScheduleApiService api;

  DateTime lastFetch;
  List<Show> shows;

  Future<Show> getShow(int id) async {
    if (needsRefresh) {
      await refreshShows();
    }
    return shows.firstWhere((element) => element.id == id, orElse: () => null);
  }

  Future<void> refreshShows() async {
    shows = await api.getShows();
    this.lastFetch = DateTime.now();
  }

  bool get needsRefresh =>
      lastFetch == null || DateTime.now().difference(lastFetch).inHours > 23;
}
