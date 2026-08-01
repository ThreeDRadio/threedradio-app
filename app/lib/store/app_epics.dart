import 'package:dio/dio.dart';
import 'package:player/audio/background_task.dart';
import 'package:player/environment/environment.dart';
import 'package:player/services/new_api/schedule_api.dart';
import 'package:player/services/on_demand_api.dart';
import 'package:player/store/app_state.dart';
import 'package:player/store/audio/audio_epics.dart';
import 'package:player/store/history/history_epics.dart';
import 'package:player/store/on_demand_episodes/on_demand_episodes_epics.dart';
import 'package:player/store/on_demand_programs/on_demand_epics.dart';
import 'package:player/store/shows/shows_epics.dart';
import 'package:redux_epics/redux_epics.dart';

final dio = Dio();
final onDemandApi = OnDemandApiService(
  http: dio,
  apiKey: Environment.onDemandApiKey,
  baseUrl: Environment.onDemandApi,
);

final newApi = NewScheduleApi(
  dio: dio,
  baseUrl: 'https://threedradio.com/wp-json/radio-logic/v1',
);

Epic<AppState> buildEpics(ThreeDBackgroundTask audioService) {
  return combineEpics<AppState>([
    AudioEpics(audioService).call,
    HistoryEpics().call,
    OnDemandEpisodesEpics(api: onDemandApi).call,
    OnDemandEpics(api: onDemandApi).call,
    ShowsEpics(api: newApi).call,
  ]);
}
