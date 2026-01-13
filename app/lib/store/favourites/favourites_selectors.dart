import 'package:player/services/wp_schedule_api.dart';
import 'package:player/store/app_state.dart';

getFavouritesShows(AppState state) {
  return state.favourites.entities.values
      .map((id) => state.shows.entities[id])
      .where((val) => val != null)
      .cast<Show>()
      .toList();
}
