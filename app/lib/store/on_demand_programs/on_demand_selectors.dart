import 'package:player/services/on_demand_api.dart';
import 'package:player/services/wp_schedule_api.dart';
import 'package:player/store/app_state.dart';
import 'package:player/store/schedules/schedules_selectors.dart';
import 'package:player/store/shows/shows_selectors.dart';
import 'package:redux_entity/redux_entity.dart';

RemoteEntityState<OnDemandProgram> getOnDemandProgramState(AppState s) =>
    s.onDemandPrograms;

Map<String, OnDemandProgram> getOnDemandEntities(AppState s) =>
    getOnDemandProgramState(s).entities;

List<Show> getShowsForOnDemandStreaming(AppState s) {
  final onDemand = getOnDemandEntities(s);
  final shows = getShowEntities(s).values;

  final List<Show> sorted = shows.where((s) {
    final onDemandKey = s.onDemandShowId;
    return onDemand[onDemandKey] != null;
  }).toList();

  sorted.sort((a, b) => a.title.text.compareTo(b.title.text));

  return sorted;
}

List<OnDemandEpisode> getEpisodesForShow(AppState state, Show show) {
  final possibleEpisodes =
      state.onDemandEpisodes.entities[show.onDemandShowId]?.reversed.toList() ??
          <OnDemandEpisode>[];

  return possibleEpisodes.where((episode) {
    final week = weekNumber(date: DateTime.parse(episode.date));

    final schedule =
        getScheduleForDate(state, DateTime.parse(episode.date).toLocal());
    final List<int> showIds = schedule?.shows
            .where((e) => e.show_id[0].isNotEmpty)
            .map((e) => int.tryParse(e.show_id[0].trim()) ?? 0)
            .toList() ??
        [];
    return showIds.contains(show.id);
  }).toList();
}
