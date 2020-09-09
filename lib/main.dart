import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:player/screens/home_screen.dart';
import 'package:player/store/app_epics.dart';
import 'package:player/store/app_reducer.dart';
import 'package:player/store/app_state.dart';
import 'package:redux/redux.dart';
import 'package:redux_epics/redux_epics.dart';
import 'package:redux_persist/redux_persist.dart';
import 'package:redux_persist_flutter/redux_persist_flutter.dart';
import 'package:redux_remote_devtools/redux_remote_devtools.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:sentry/sentry.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  final persistor = Persistor<AppState>(
    storage: FlutterStorage(
      location: FlutterSaveLocation.documentFile,
    ), // Or use other engines
    serializer: JsonSerializer<AppState>((json) {
      return AppState.fromJson(json);
    }), // Or use other serializers
  );

  // Load initial state
  AppState initialState;
  try {
    initialState = await persistor.load();
  } catch (err) {
    print(err);
  }

  final remoteDev = RemoteDevToolsMiddleware('192.168.1.207:8000');

  final store = Store<AppState>(
    appReducer,
    initialState: initialState ?? AppState(),
    middleware: [
      EpicMiddleware(appEpics),
      persistor.createMiddleware(),
      remoteDev
    ],
  );

  remoteDev.store = store;
  await remoteDev.connect();

  final sentry = SentryClient(
    dsn:
        "https://bd6bdccfd169415fa82fca062ad02b25@o120815.ingest.sentry.io/5421277",
  );
  runZonedGuarded(
      () => runApp(
            MyApp(
              store: store,
            ),
          ), (error, stackTrace) async {
    await sentry.captureException(
      exception: error,
      stackTrace: stackTrace,
    );
  });
}

class MyApp extends StatelessWidget {
  MyApp({@required this.store});

  final Store<AppState> store;

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          brightness: Brightness.dark,
          accentColor: Color(0xff2F9B17),
          buttonColor: Color(0xff2F9B17),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          textTheme: TextTheme(
            bodyText2: GoogleFonts.openSans(fontSize: 16),
            button: GoogleFonts.arvo(fontWeight: FontWeight.bold),
            headline2: GoogleFonts.arvo(),
            headline3: GoogleFonts.arvo(color: Colors.white, fontSize: 36),
            headline4: GoogleFonts.arvo(
              fontWeight: FontWeight.bold,
              fontSize: 32,
              shadows: [
                Shadow(offset: Offset(0, 4)),
              ],
            ),
            headline5: GoogleFonts.arvo(
              color: Colors.white,
            ),
            headline6: GoogleFonts.arvo(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          primaryTextTheme: GoogleFonts.arvoTextTheme(
            TextTheme(
              headline6: TextStyle(color: Colors.white),
            ),
          ),
        ),
        routes: {
          '/': (context) => AudioServiceWidget(
                child: HomeScreen(),
              ),
        },
        initialRoute: '/',
      ),
    );
  }
}
