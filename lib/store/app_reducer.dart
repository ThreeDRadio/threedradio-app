import 'package:player/services/wp_schedule_api.dart';
import 'package:player/store/app_state.dart';
import 'package:redux_entity/redux_entity.dart';

AppState appReducer(AppState state, dynamic action) => AppState(
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
