import 'package:flutter_test/flutter_test.dart';
import 'package:player/store/app_state.dart';

void main() {
  group(AppState, () {
    group('fromJson', () {
      test('deserializes on demand episodes', () {
        final json = {
          'onDemandEpisodes': {
            'ids': ['show1', 'show2'],
            'loadingIds': {},
            'updateTimes': {},
            'entities': {
              'show1': [
                {
                  'id': 'ep1',
                  'showId': 'show1',
                  'showSlug': 'show1',
                }
              ],
              'show2': [
                {
                  'id': 'ep2',
                  'showId': 'show2',
                  'showSlug': 'show2',
                },
                {
                  'id': 'ep3',
                  'showId': 'show2',
                  'showSlug': 'show2',
                }
              ]
            }
          },
          'onDemandPrograms': {
            'ids': [],
            'loadingIds': <String, dynamic>{},
            'updateTimes': <String, dynamic>{},
            'entities': <String, dynamic>{}
          },
          'schedules': {
            'ids': [],
            'loadingIds': <String, dynamic>{},
            'updateTimes': <String, dynamic>{},
            'entities': <String, dynamic>{}
          },
          'shows': {
            'ids': [],
            'loadingIds': <String, dynamic>{},
            'updateTimes': <String, dynamic>{},
            'entities': <String, dynamic>{}
          }
        };
        final result = AppState.fromJson(json);
        expect(result.onDemandEpisodes.ids, ['show1', 'show2']);
        expect(result.onDemandEpisodes.entities['show1'].length, 1);
        expect(result.onDemandEpisodes.entities['show2'].length, 2);
      });
    });
  });
}
