import 'package:player/services/on_demand_api.dart';
import 'package:player/store/on_demand_programs/on_demand_epics.dart';

class RequestPlayLive {}

class SuccessPlayLive {}

class RequestPause {}

class SuccessPause {}

class RequestResume {}

class SuccessResume {}

class RequestStop {}

class SuccessStop {}

class RequestPlayEpisode {
  const RequestPlayEpisode({this.episode});
  final OnDemandEpisode episode;
}

class SuccessPlayEpisode {}
