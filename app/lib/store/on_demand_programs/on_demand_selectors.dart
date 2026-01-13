import 'package:player/services/new_api/dto/show_dto.dart';
import 'package:player/services/on_demand_api.dart';
import 'package:player/store/app_state.dart';
import 'package:player/store/schedules/schedules_selectors.dart';
import 'package:player/store/shows/shows_selectors.dart';
import 'package:redux_entity/redux_entity.dart';

RemoteEntityState<OnDemandProgram> getOnDemandProgramState(AppState s) =>
    s.onDemandPrograms;

Map<String, OnDemandProgram> getOnDemandEntities(AppState s) =>
    getOnDemandProgramState(s).entities;

List<ShowDto> getShowsForOnDemandStreaming(AppState s) {
  final onDemand = getOnDemandEntities(s);
  final shows = getShowEntities(s).values;

  final List<ShowDto> sorted = shows.where((s) {
    final onDemandKey = s.onDemandShowId;
    return onDemand[onDemandKey] != null;
  }).toList();

  sorted.sort((a, b) => a.sortKey.compareTo(b.sortKey));

  return sorted;
}

List<OnDemandEpisode> getEpisodesForShow(AppState state, ShowDto show) {
  final possibleEpisodes =
      state.onDemandEpisodes.entities[show.onDemandShowId]?.reversed.toList() ??
      <OnDemandEpisode>[];

  return possibleEpisodes.where((episode) {
    final schedule = getScheduleForDate(
      state,
      DateTime.parse(episode.date).toLocal(),
    );
    final List<int> showIds =
        schedule?.shows
            .where((e) => e.show_id[0].isNotEmpty)
            .map((e) => int.tryParse(e.show_id[0].trim()) ?? 0)
            .toList() ??
        [];
    return showIds.contains(show.id);
  }).toList();
}
