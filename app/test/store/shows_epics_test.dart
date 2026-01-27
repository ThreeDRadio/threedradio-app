import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:player/services/new_api/dto/show_dto.dart';
import 'package:player/services/new_api/schedule_api.dart';
import 'package:player/store/app_state.dart';
import 'package:player/store/shows/shows_epics.dart';
import 'package:redux/redux.dart';
import 'package:redux_entity/redux_entity.dart';
import 'package:redux_epics/redux_epics.dart';

import 'shows_epics_test.mocks.dart';

ShowDto buildShow({required int id}) {
  return ShowDto(
    id: Random().nextInt(1000),
    description: 'Test',
    link: 'http://example.com',
    name: 'test',
    slug: 'test',
  );
}

@GenerateMocks([NewScheduleApi])
void main() {
  late MockNewScheduleApi api;
  late ShowsEpics epics;
  late EpicStore<AppState> store;

  setUp(() {
    api = MockNewScheduleApi();
    epics = ShowsEpics(api: api);
    store = EpicStore<AppState>(
      Store<AppState>((state, action) => state, initialState: AppState()),
    );
  });

  group(ShowsEpics, () {
    group('fetchShows', () {
      test('basic success path', () async {
        when(api.getAllPrograms()).thenAnswer(
          (realInvocation) =>
              Future.value([buildShow(id: 1), buildShow(id: 2)]),
        );
        await expectLater(
          epics.call(
            Stream<dynamic>.fromIterable([
              const RequestRetrieveAll<ShowDto>(),
            ]).asBroadcastStream(),
            store,
          ),
          emitsInAnyOrder([isA<SuccessRetrieveAll<ShowDto>>()]),
        );
      });
      test('Returnes cached if we have requested recently', () async {
        when(api.getAllPrograms()).thenAnswer(
          (realInvocation) =>
              Future.value([buildShow(id: 1), buildShow(id: 2)]),
        );
        store = EpicStore<AppState>(
          Store<AppState>(
            (state, action) => state,
            initialState: AppState(
              shows: RemoteEntityState<ShowDto>(
                entities: {'1': buildShow(id: 1), '2': buildShow(id: 2)},
                ids: ['1', '2'],
                lastFetchAllTime: DateTime.now(),
              ),
            ),
          ),
        );
        expectLater(
          epics.call(
            Stream<dynamic>.fromIterable([
              const RequestRetrieveAll<ShowDto>(),
            ]).asBroadcastStream(),
            store,
          ),
          emitsInAnyOrder([isA<SuccessRetrieveAllFromCache<ShowDto>>()]),
        );
        verifyNever(api.getAllPrograms());
      });
      test('API fail path', () async {
        when(
          api.getAllPrograms(),
        ).thenAnswer((realInvocation) => Future.error('some error'));
        expectLater(
          epics.call(
            Stream<dynamic>.fromIterable([
              const RequestRetrieveAll<ShowDto>(),
            ]).asBroadcastStream(),
            store,
          ),
          emitsInAnyOrder([isA<FailRetrieveAll<ShowDto>>()]),
        );
      });
    });
  });
}
