import 'package:json_annotation/json_annotation.dart';
import 'package:player/services/on_demand_api.dart';
import 'package:player/services/wp_schedule_api.dart';
import 'package:player/store/audio/audio_state.dart';
import 'package:player/store/favourites/favourites_actions.dart';
import 'package:player/store/history/history_item.dart';
import 'package:redux_entity/redux_entity.dart';

part 'app_state.g.dart';

@JsonSerializable(createFactory: false)
class AppState {
  const AppState({
    this.audio = const AudioState(),
    this.favourites = const EntityState<Favourite>(),
    this.history = const EntityState<HistoryItem>(),
    this.onDemandEpisodes = const RemoteEntityState<List<OnDemandEpisode>>(),
    this.onDemandPrograms = const RemoteEntityState<OnDemandProgram>(),
    this.schedules = const RemoteEntityState<Schedule>(),
    this.shows = const RemoteEntityState<Show>(),
  });

  final AudioState audio;
  final EntityState<Favourite> favourites;
  final EntityState<HistoryItem> history;
  final RemoteEntityState<List<OnDemandEpisode>> onDemandEpisodes;
  final RemoteEntityState<OnDemandProgram> onDemandPrograms;
  final RemoteEntityState<Schedule> schedules;
  final RemoteEntityState<Show> shows;

  factory AppState.fromJson(Map<String, dynamic> json) {
    return AppState(
      favourites: json['favourites'] != null
          ? EntityState<Favourite>.fromJson(
              json['favourites'],
              (json) => Favourite.fromJson(json),
            )
          : EntityState<Favourite>(),
      history: json['history'] != null
          ? EntityState<HistoryItem>.fromJson(
              json['history'],
              (json) => HistoryItem.fromJson(json),
            )
          : EntityState<HistoryItem>(),
      onDemandEpisodes: RemoteEntityState<List<OnDemandEpisode>>.fromJson(
        json['onDemandEpisodes'],
        (json) {
          List<dynamic> entries = json;
          return entries.map((item) => OnDemandEpisode.fromJson(item)).toList();
        },
      ),
      onDemandPrograms: RemoteEntityState<OnDemandProgram>.fromJson(
        json['onDemandPrograms'],
        (json) => OnDemandProgram.fromJson(json),
      ),
      schedules: RemoteEntityState<Schedule>.fromJson(
        json['schedules'],
        (json) => Schedule.fromJson(json),
      ),
      shows: RemoteEntityState<Show>.fromJson(
        json['shows'],
        (json) => Show.fromJson(json),
      ),
    );
  }

  Map<String, dynamic> toJson() => _$AppStateToJson(this);
}
