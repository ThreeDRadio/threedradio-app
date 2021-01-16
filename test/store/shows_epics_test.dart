import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:player/services/wp_schedule_api.dart';
import 'package:player/store/app_state.dart';
import 'package:player/store/shows/shows_epics.dart';
import 'package:redux_entity/redux_entity.dart';
import 'package:redux_epics/redux_epics.dart';

class MockApi extends Mock implements WpScheduleApiService {}

class MockStore extends Mock implements EpicStore<AppState> {}

void main() {
  MockApi api;
  ShowsEpics epics;
  MockStore store;

  setUp(() {
    api = MockApi();
    epics = ShowsEpics(api: api);
    store = MockStore();
  });

  group(ShowsEpics, () {
    group('fetchShows', () {
      test('basic success path', () async {
        when(api.getShows()).thenAnswer(
          (realInvocation) => Future.value(
            [
              Show(id: 1),
              Show(id: 2),
            ],
          ),
        );
        when(store.state).thenReturn(AppState());
        expectLater(
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
              Show(id: 1),
              Show(id: 2),
            ],
          ),
        );
        when(store.state).thenReturn(
          AppState(
            shows: RemoteEntityState<Show>(
              entities: {
                '1': Show(id: 1),
                '2': Show(id: 2),
              },
              ids: ['1', '2'],
              lastFetchAllTime: DateTime.now(),
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
        when(store.state).thenReturn(AppState());
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
