import 'package:flutter_test/flutter_test.dart';
import 'package:player/services/wp_schedule_api.dart';
import 'package:player/store/app_state.dart';
import 'package:player/store/shows/shows_selectors.dart';
import 'package:redux_entity/redux_entity.dart';

void main() {
  group('shows selectors', () {
    test('getShowState', () {
      final showsState = RemoteEntityState<Show>();
      final state = AppState(shows: showsState);
      expect(getShowState(state), showsState);
    });

    test('getShowEntities', () {
      final entities = {
        'id1': Show(slug: 'some show'),
      };
      final showsState = RemoteEntityState<Show>(
        entities: entities,
      );
      final state = AppState(shows: showsState);
      expect(getShowEntities(state), entities);
    });
    test('getShowEntitiesBySlug', () {
      final entities = {
        'id1': Show(slug: 'some show'),
      };
      final showsState = RemoteEntityState<Show>(
        entities: entities,
      );
      final state = AppState(shows: showsState);
      final result = getShowEntitiesBySlug(state);
      expect(result['some show'], entities['id1']);
    });
  });
}
