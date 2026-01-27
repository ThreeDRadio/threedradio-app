import 'package:player/services/new_api/dto/show_dto.dart';
import 'package:player/store/app_state.dart';

getFavouritesShows(AppState state) {
  return state.favourites.entities.values
      .map((id) => state.shows.entities[id])
      .where((val) => val != null)
      .cast<ShowDto>()
      .toList();
}
