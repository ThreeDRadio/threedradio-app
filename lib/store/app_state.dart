import 'package:json_annotation/json_annotation.dart';
import 'package:player/services/wp_schedule_api.dart';
import 'package:redux_entity/redux_entity.dart';

part 'app_state.g.dart';

@JsonSerializable(createFactory: false)
class AppState {
  const AppState({
    this.schedules = const RemoteEntityState<Schedule>(),
    this.shows = const RemoteEntityState<Show>(),
  });

  final RemoteEntityState<Schedule> schedules;
  final RemoteEntityState<Show> shows;

  factory AppState.fromJson(Map<String, dynamic> json) {
    return AppState(
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
