import 'package:player/services/wp_schedule_api.dart';
import 'package:player/store/app_state.dart';
import 'package:redux_entity/redux_entity.dart';

RemoteEntityState<Show> getShowState(AppState s) => s.shows;

Map<String, Show> getShowEntities(AppState s) => getShowState(s).entities;

/// Returns a map of shows where key = show.slug.
/// Useful for converting from integer show ids used by wordpress
/// to the slug used by the on-demand system.
Map<String, Show> getShowEntitiesBySlug(AppState s) {
  return getShowEntities(s).map((key, value) => MapEntry(value.slug, value));
}
