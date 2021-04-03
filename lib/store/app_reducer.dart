import 'package:player/services/on_demand_api.dart';
import 'package:player/services/wp_schedule_api.dart';
import 'package:player/store/app_state.dart';
import 'package:player/store/audio/audio_reducer.dart';
import 'package:player/store/favourites/favourites_actions.dart';
import 'package:player/store/history/history_reducer.dart';
import 'package:redux_entity/redux_entity.dart';

AppState appReducer(AppState state, dynamic action) => AppState(
      audio: audioReducer(state.audio, action),
      favourites: LocalEntityReducer<EntityState<Favourite>, Favourite>()(
          state.favourites, action),
      history: HistoryReducer()(state.history, action),
      onDemandEpisodes: RemoteEntityReducer<
          RemoteEntityState<List<OnDemandEpisode>>,
          List<OnDemandEpisode>>(selectId: (value) => value.first.showId)(
        state.onDemandEpisodes,
        action,
      ),
      onDemandPrograms: RemoteEntityReducer<RemoteEntityState<OnDemandProgram>,
          OnDemandProgram>()(
        state.onDemandPrograms,
        action,
      ),
      schedules: RemoteEntityReducer<RemoteEntityState<Schedule>, Schedule>(
          selectId: (entity) => entity.id.toString())(
        state.schedules,
        action,
      ),
      shows: RemoteEntityReducer<RemoteEntityState<Show>, Show>(
          selectId: (entity) => entity.id.toString())(
        state.shows,
        action,
      ),
    );
