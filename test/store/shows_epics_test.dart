import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:player/services/wp_schedule_api.dart';
import 'package:player/store/app_state.dart';
import 'package:player/store/shows/shows_epics.dart';
import 'package:redux/redux.dart';
import 'package:redux_entity/redux_entity.dart';
import 'package:redux_epics/redux_epics.dart';

import 'shows_epics_test.mocks.dart';

Show buildShow({required int id}) {
  return Show(
    content: WpText('Show $id'),
    excerpt: WpText('Show $id'),
    title: WpText('Show $id'),
    id: id,
    featured_media: 0,
    thumbnail: null,
    slug: 'show-$id',
    status: 'published',
    meta: WpMeta(),
  );
}

@GenerateMocks([WpScheduleApiService])
void main() {
  late MockWpScheduleApiService api;
  late ShowsEpics epics;
  late EpicStore<AppState> store;

  setUp(() {
    api = MockWpScheduleApiService();
    epics = ShowsEpics(api: api);
    store = EpicStore<AppState>(
      Store<AppState>(
        (state, action) => state,
        initialState: AppState(),
      ),
    );
  });

  group(ShowsEpics, () {
    group('fetchShows', () {
      test('basic success path', () async {
        when(api.getShows()).thenAnswer(
          (realInvocation) => Future.value(
            [
              buildShow(id: 1),
              buildShow(id: 2),
            ],
          ),
        );
        await expectLater(
          epics.call(
              Stream<dynamic>.fromIterable([const RequestRetrieveAll<Show>()])
                  .asBroadcastStream(),
              store),
          emitsInAnyOrder(
            [isA<SuccessRetrieveAll<Show>>()],
          ),
        );
      });
      test('Returnes cached if we have requested recently', () async {
        when(api.getShows()).thenAnswer(
          (realInvocation) => Future.value(
            [
              buildShow(id: 1),
              buildShow(id: 2),
            ],
          ),
        );
        store = EpicStore<AppState>(
          Store<AppState>(
            (state, action) => state,
            initialState: AppState(
              shows: RemoteEntityState<Show>(
                entities: {
                  '1': buildShow(id: 1),
                  '2': buildShow(id: 2),
                },
                ids: ['1', '2'],
                lastFetchAllTime: DateTime.now(),
              ),
            ),
          ),
        );
        expectLater(
          epics.call(
              Stream<dynamic>.fromIterable([const RequestRetrieveAll<Show>()])
                  .asBroadcastStream(),
              store),
          emitsInAnyOrder(
            [isA<SuccessRetrieveAllFromCache<Show>>()],
          ),
        );
        verifyNever(api.getShows());
      });
      test('API fail path', () async {
        when(api.getShows()).thenAnswer(
          (realInvocation) => Future.error('some error'),
        );
        expectLater(
          epics.call(
              Stream<dynamic>.fromIterable([const RequestRetrieveAll<Show>()])
                  .asBroadcastStream(),
              store),
          emitsInAnyOrder(
            [isA<FailRetrieveAll<Show>>()],
          ),
        );
      });
    });
  });
}
