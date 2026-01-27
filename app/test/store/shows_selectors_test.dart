import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:player/services/new_api/dto/show_dto.dart';
import 'package:player/store/app_state.dart';
import 'package:player/store/on_demand_programs/on_demand_selectors.dart';
import 'package:player/store/shows/shows_selectors.dart';
import 'package:redux_entity/redux_entity.dart';

ShowDto buildShow({int? id, String? slug}) {
  id ??= Random().nextInt(100);
  return ShowDto(
    name: 'Show $id',
    id: id,
    slug: 'show-$id',
    description: 'blah',
    link: 'http://example.com',
  );
}

void main() {
  group('shows selectors', () {
    test('getShowState', () {
      final showsState = RemoteEntityState<ShowDto>();
      final state = AppState(shows: showsState);
      expect(getShowState(state), showsState);
    });

    test('getShowEntities', () {
      final entities = {'id1': buildShow(slug: 'some show')};
      final showsState = RemoteEntityState<ShowDto>(entities: entities);
      final state = AppState(shows: showsState);
      expect(getShowEntities(state), entities);
    });
    test('getShowEntitiesBySlug', () {
      final entities = {'id1': buildShow(slug: 'some show')};
      final showsState = RemoteEntityState<ShowDto>(entities: entities);
      final state = AppState(shows: showsState);
      final result = getShowEntitiesBySlug(state);
      expect(result['some show'], entities['id1']);
    });
  });

  group('Odd/Even Week Calculation', () {
    test('iSOddWeek', () {
      // 2026-01-01 is a Thursday
      expect(isOddWeek(DateTime(2026, 1, 1)), true);

      // which means we expect the week to change on Monday the 5th
      expect(isOddWeek(DateTime(2026, 1, 5)), false);
    });
  });
}
