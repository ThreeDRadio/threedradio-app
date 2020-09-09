import 'package:dio/dio.dart';
import 'package:player/services/wp_schedule_api.dart';
import 'package:player/store/app_state.dart';
import 'package:player/store/schedules/schedules_epics.dart';
import 'package:player/store/shows/shows_epics.dart';
import 'package:redux_epics/redux_epics.dart';

final dio = Dio();
final wpApi = WpScheduleApiService(http: dio);

final appEpics = combineEpics<AppState>([
  SchedulesEpics(api: wpApi),
  ShowsEpics(api: wpApi),
]);
