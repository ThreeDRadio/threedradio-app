import 'package:json_annotation/json_annotation.dart';
import 'package:player/services/new_api/dto/show_dto.dart';
import 'package:player/services/on_demand_api.dart';
import 'package:player/store/audio/audio_state.dart';
import 'package:player/store/favourites/favourites_actions.dart';
import 'package:player/store/history/history_item.dart';
import 'package:player/store/settings/settings_state.dart';
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
    this.shows = const RemoteEntityState<ShowDto>(),
    this.settings = const SettingsState(),
  });

  final AudioState audio;
  final EntityState<Favourite> favourites;
  final EntityState<HistoryItem> history;
  final RemoteEntityState<List<OnDemandEpisode>> onDemandEpisodes;
  final RemoteEntityState<OnDemandProgram> onDemandPrograms;
  final RemoteEntityState<ShowDto> shows;
  final SettingsState settings;

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
      shows: RemoteEntityState<ShowDto>.fromJson(
        json['shows'],
        (json) => ShowDto.fromJson(json),
      ),
      settings: json['settings'] != null
          ? SettingsState.fromJson(json['settings'])
          : const SettingsState(),
    );
  }

  Map<String, dynamic> toJson() => _$AppStateToJson(this);
}
