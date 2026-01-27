import 'package:player/services/new_api/dto/show_dto.dart';
import 'package:player/store/app_state.dart';
import 'package:redux_entity/redux_entity.dart';

RemoteEntityState<ShowDto> getShowState(AppState s) => s.shows;

Map<String, ShowDto> getShowEntities(AppState s) => getShowState(s).entities;

/// Returns a map of shows where key = show.slug.
/// Useful for converting from integer show ids used by wordpress
/// to the slug used by the on-demand system.
Map<String, ShowDto> getShowEntitiesBySlug(AppState s) {
  return getShowEntities(s).map((key, value) => MapEntry(value.slug, value));
}
