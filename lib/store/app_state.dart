import 'package:json_annotation/json_annotation.dart';
import 'package:player/services/on_demand_api.dart';
import 'package:player/services/wp_schedule_api.dart';
import 'package:redux_entity/redux_entity.dart';

part 'app_state.g.dart';

@JsonSerializable(createFactory: false)
class AppState {
  const AppState({
    this.onDemandPrograms = const RemoteEntityState<OnDemandProgram>(),
    this.schedules = const RemoteEntityState<Schedule>(),
    this.shows = const RemoteEntityState<Show>(),
  });

  final RemoteEntityState<OnDemandProgram> onDemandPrograms;
  final RemoteEntityState<Schedule> schedules;
  final RemoteEntityState<Show> shows;

  factory AppState.fromJson(Map<String, dynamic> json) {
    return AppState(
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
