import 'package:player/services/wp_schedule_api.dart';
import 'package:player/store/app_state.dart';
import 'package:redux_entity/redux_entity.dart';

RemoteEntityState<Show> getShowState(AppState s) => s.shows;

Map<String, Show> getShowEntities(AppState s) => getShowState(s).entities;

Map<String, Show> getShowEntitiesBySlug(AppState s) {
  return getShowEntities(s).map((key, value) => MapEntry(value.slug, value));
}
