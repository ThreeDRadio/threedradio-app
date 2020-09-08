import 'package:flutter/foundation.dart';

import 'package:player/services/on_demand_api.dart';

class OnDemandProvider {
  OnDemandProvider({
    @required this.api,
  });

  final OnDemandApiService api;

  Future<List<OnDemandProgram>> getOnDemandPrograms() {}
}
