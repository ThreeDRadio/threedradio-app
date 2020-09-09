import 'package:player/services/on_demand_api.dart';
import 'package:player/services/wp_schedule_api.dart';
import 'package:player/store/app_state.dart';
import 'package:redux_entity/redux_entity.dart';

AppState appReducer(AppState state, dynamic action) => AppState(
      onDemandPrograms: RemoteEntityReducer<RemoteEntityState<OnDemandProgram>,
          OnDemandProgram>(selectId: (item) => item.slug)(
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
