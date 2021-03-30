import 'package:player/services/on_demand_api.dart';
import 'package:player/store/app_state.dart';
import 'package:redux_entity/redux_entity.dart';
import 'package:redux_epics/redux_epics.dart';

class OnDemandEpisodesEpics extends EpicClass<AppState> {
  OnDemandEpisodesEpics({required this.api});

  final OnDemandApiService api;

  Stream<dynamic> call(
      Stream<dynamic> actions, EpicStore<AppState> store) async* {
    await for (final action in actions) {
      if (action is RequestRetrieveOne<List<OnDemandEpisode>>) {
        final now = DateTime.now();
        if (store.state.onDemandEpisodes.updateTimes[action.id] == null ||
            now.difference(store.state.shows.lastFetchAllTime!).inMinutes >
                30) {
          final episodes = await api.getEpisodes(action.id);
          yield SuccessRetrieveOne<List<OnDemandEpisode>>(episodes);
        } else {
          yield SuccessRetrieveOneFromCache<List<OnDemandEpisode>>(store.state
              .onDemandEpisodes.entities[action.id] as List<OnDemandEpisode>);
        }
      }
    }
  }
}
