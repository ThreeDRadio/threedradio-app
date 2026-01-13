import 'package:player/services/wp_schedule_api.dart';
import 'package:player/store/app_state.dart';
import 'package:player/store/playlists/playlist_class.dart';
import 'package:player/store/shows/shows_selectors.dart';
import 'package:redux_entity/redux_entity.dart';
import 'package:redux_epics/redux_epics.dart';

class PlaylistEpics extends EpicClass<AppState> {
  PlaylistEpics({
    required this.api,
  });

  final WpScheduleApiService api;

  Stream<dynamic> call(
      Stream<dynamic> actions, EpicStore<AppState> store) async* {
    await for (final action in actions) {
      if (action is RequestRetrieveOne<EpisodePlaylistGlue>) {
        final parts = action.id.split('::');
        final showSlug = parts.first.replaceAll('+', '-').toLowerCase();
        final episodeDate = parts.last;

        final show = getShowEntitiesBySlug(store.state)[showSlug];
        if (show?.meta.show_category?.isEmpty ?? true) {
          yield FailRetrieveOne<EpisodePlaylistGlue>(id: action.id);
          continue;
        }
        final categorySlug = show!.meta.show_category!.first;

        // find category
        final category = await api.getCategoryBySlug(categorySlug);

        if (category == null) {
          yield FailRetrieveOne<EpisodePlaylistGlue>(id: action.id);
        }

        // find posts that match category
        final posts = await api.findPosts({
          'category': category!.id,
          'search': episodeDate,
        });
        if (posts.isNotEmpty) {
          yield SuccessRetrieveOne<EpisodePlaylistGlue>(EpisodePlaylistGlue(
            id: action.id,
            playlist: posts.first,
          ));
        } else {
          yield FailRetrieveOne<EpisodePlaylistGlue>(id: action.id);
          continue;
        }
      }
    }
  }
}
