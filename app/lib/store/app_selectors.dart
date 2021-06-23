import 'package:player/store/app_state.dart';

bool somethingLoading(AppState s) {
  return s.onDemandEpisodes.loadingAll ||
      s.onDemandPrograms.loadingAll ||
      s.shows.loadingAll ||
      s.schedules.loadingAll;
}
