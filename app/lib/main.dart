import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:player/audio/background_task.dart';
import 'package:player/generated/l10n.dart';
import 'package:player/screens/about_screen.dart';
import 'package:player/screens/favourites_screen.dart';
import 'package:player/screens/home_screen.dart';
import 'package:player/store/app_epics.dart';
import 'package:player/store/app_reducer.dart';
import 'package:player/store/app_state.dart';
import 'package:player/store/audio/app_actions.dart';
import 'package:redux/redux.dart';
import 'package:redux_epics/redux_epics.dart';
import 'package:redux_persist/redux_persist.dart';
import 'package:redux_persist_flutter/redux_persist_flutter.dart';
import 'package:redux_remote_devtools/redux_remote_devtools.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:sentry/sentry.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  bool debug = false;
  assert(() {
    debug = true;
    return true;
  }());

  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await Firebase.initializeApp();

  final audioService = ThreeDBackgroundTask();
  AudioService.init(
    builder: () => audioService,
    config: AudioServiceConfig(
      androidNotificationIcon: 'drawable/ic_threedradio',
    ),
  );

  await Firebase.initializeApp();
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  final persistor = Persistor<AppState>(
    storage: FlutterStorage(
      location: FlutterSaveLocation.documentFile,
    ), // Or use other engines
    serializer: JsonSerializer<AppState>((json) {
      return AppState.fromJson(json);
    }), // Or use other serializers
  );

  // Load initial state
  AppState? initialState;
  try {
    initialState = await persistor.load();
  } catch (err, trace) {
    print(err);
    print(trace);
  }

  final remoteDev = RemoteDevToolsMiddleware('localhost:8000');

  final store = Store<AppState>(
    appReducer,
    initialState: initialState ?? AppState(),
    middleware: [
      EpicMiddleware(buildEpics(audioService)),
      persistor.createMiddleware(),
      if (debug) remoteDev,
    ],
  );

  if (debug) {
    remoteDev.store = store;
    //await remoteDev.connect();
  }

  store.dispatch(AppStartAction());

  SentryClient? sentry;

  if (!debug) {
    sentry = SentryClient(
      SentryOptions(
        dsn:
            "https://bd6bdccfd169415fa82fca062ad02b25@o120815.ingest.sentry.io/5421277",
      ),
    );
  }
  if (sentry != null) {
    FlutterError.onError = (details, {bool forceReport = false}) {
      try {
        sentry?.captureException(details.exception, stackTrace: details.stack);
      } catch (e) {
        print('Sending report to sentry.io failed: $e');
      } finally {
        // Also use Flutter's pretty error logging to the device's console.
        FlutterError.dumpErrorToConsole(details, forceReport: forceReport);
      }
    };
  }
  runZonedGuarded(() => runApp(MyApp(store: store, analytics: analytics)), (
    error,
    stackTrace,
  ) async {
    if (sentry != null) {
      await sentry.captureException(error, stackTrace: stackTrace);
    }
    print(error);
  });
}

class MyApp extends StatelessWidget {
  MyApp({required this.analytics, required this.store});

  final Store<AppState> store;
  final FirebaseAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorObservers: [FirebaseAnalyticsObserver(analytics: analytics)],
        localizationsDelegates: [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        title: 'Three D Radio',
        theme: ThemeData(
          brightness: Brightness.light,
          colorScheme: ColorScheme.light().copyWith(
            primary: Color(0xff2F9B17),
            surface: Color(0xfff2ebda),
          ),
          indicatorColor: Color(0xff2F9B17),
          appBarTheme: AppBarThemeData(
            backgroundColor: Color.fromARGB(255, 50, 46, 45),
            iconTheme: IconThemeData(color: Color(0xfff2ebda)),
            titleTextStyle: TextStyle(
              color: Color(0xfff2ebda),
              fontFamily: GoogleFonts.jockeyOne().fontFamily,
              fontSize: 22,
            ),
          ),
          drawerTheme: DrawerThemeData(
            backgroundColor: Color.fromARGB(255, 50, 46, 45),
          ),
          listTileTheme: ListTileThemeData(
            iconColor: Color(0xfff2ebda),
            textColor: Color(0xfff2ebda),
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          chipTheme: ChipThemeData(
            labelStyle: GoogleFonts.barlowCondensed(fontSize: 14),
          ),
          textTheme: TextTheme(
            bodyLarge: GoogleFonts.barlowCondensed(fontSize: 18),
            bodyMedium: GoogleFonts.barlowCondensed(fontSize: 16),
            bodySmall: GoogleFonts.barlowCondensed(fontSize: 14),
            labelLarge: GoogleFonts.barlowCondensed(
              fontWeight: FontWeight.bold,
            ),
            displayMedium: GoogleFonts.vinaSans(fontSize: 40),
            displaySmall: GoogleFonts.vinaSans(fontSize: 36),
            headlineMedium: GoogleFonts.vinaSans(
              fontSize: 32,
              height: 1,
            ),
            headlineSmall: GoogleFonts.vinaSans(),
            titleLarge: GoogleFonts.vinaSans(fontSize: 18),
          ),
          primaryTextTheme: GoogleFonts.vinaSansTextTheme(
            TextTheme(titleLarge: TextStyle(color: Colors.white)),
          ),
          sliderTheme: SliderThemeData(
            activeTrackColor: Colors.black,
            thumbColor: Colors.black,
            inactiveTrackColor: Colors.black,
            overlayColor: Colors.black.withAlpha(40),
          ),
        ),
        routes: {
          '/': (context) => HomeScreen(),
          '/about': (context) => AboutScreen(),
          '/favourites': (context) => FavouritesScreen(),
        },
        initialRoute: '/',
      ),
    );
  }
}
