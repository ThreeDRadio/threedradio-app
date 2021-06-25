import 'package:player/services/on_demand_api.dart';
import 'package:player/services/wp_schedule_api.dart';
import 'package:player/store/app_state.dart';
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
    print(onDemandKey);
    return onDemand[onDemandKey] != null;
  }).toList();

  sorted.sort((a, b) => a.title.text.compareTo(b.title.text));

  return sorted;
}
