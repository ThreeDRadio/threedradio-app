import 'package:player/store/app_state.dart';

getFavouritesShows(AppState state) {
  return state.favourites.entities.keys
      .map((id) => state.shows.entities[id])
      .toList();
}
