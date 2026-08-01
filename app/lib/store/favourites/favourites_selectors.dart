import 'package:player/services/new_api/dto/show_dto.dart';
import 'package:player/store/app_state.dart';

List<ShowDto> getFavouritesShows(AppState state) {
  return state.favourites.entities.values
      .map((fave) => state.shows.entities[fave.id])
      .where((val) => val != null)
      .cast<ShowDto>()
      .toList();
}
