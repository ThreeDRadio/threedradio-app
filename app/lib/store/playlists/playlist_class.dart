import 'package:player/services/wp_schedule_api.dart';

class EpisodePlaylistGlue {
  const EpisodePlaylistGlue({
    required this.id,
    required this.playlist,
  });
  final String id;
  final WpPost playlist;

  Map<String, dynamic> toJson() => {'id': id, 'playlist': playlist};
}
