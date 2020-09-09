import 'package:dio/dio.dart';
import 'package:player/environment/environment.dart';
import 'package:player/services/on_demand_api.dart';
import 'package:player/services/wp_schedule_api.dart';
import 'package:player/store/app_state.dart';
import 'package:player/store/on_demand_programs/on_demand_epics.dart';
import 'package:player/store/schedules/schedules_epics.dart';
import 'package:player/store/shows/shows_epics.dart';
import 'package:redux_epics/redux_epics.dart';

final dio = Dio();
final onDemandApi =
    OnDemandApiService(http: dio, apiKey: Environment.onDemandApiKey);
final wpApi = WpScheduleApiService(http: dio);

final appEpics = combineEpics<AppState>([
  OnDemandEpics(api: onDemandApi),
  SchedulesEpics(api: wpApi),
  ShowsEpics(api: wpApi),
]);
