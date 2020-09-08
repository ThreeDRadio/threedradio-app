import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:player/environment/environment.dart';
import 'package:player/providers/current_show_stream.dart';
import 'package:player/providers/schedule_provider.dart';
import 'package:player/providers/shows_provider.dart';
import 'package:player/screens/home_screen.dart';
import 'package:player/services/on_demand_api.dart';
import 'package:player/services/wp_schedule_api.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:sentry/sentry.dart';

void main() async {
  tz.initializeTimeZones();
  final sentry = SentryClient(dsn: "bd6bdccfd169415fa82fca062ad02b25");
  runZonedGuarded(() => runApp(MyApp()), (error, stackTrace) async {
    await sentry.captureException(
      exception: error,
      stackTrace: stackTrace,
    );
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<Dio>.value(value: Dio()),
        ProxyProvider<Dio, WpScheduleApiService>(
          update: (_, dio, __) => WpScheduleApiService(http: dio),
        ),
        ProxyProvider<Dio, OnDemandApiService>(
          update: (_, dio, __) => OnDemandApiService(
            http: dio,
            apiKey: Environment.onDemandApiKey,
          ),
        ),
        ProxyProvider<WpScheduleApiService, ScheduleProvider>(
          update: (_, api, __) => ScheduleProvider(api: api),
        ),
        ProxyProvider<WpScheduleApiService, ShowsProvider>(
          update: (_, api, __) => ShowsProvider(api: api),
        ),
        Consumer2<ScheduleProvider, ShowsProvider>(
          builder: (context, schedules, show, child) => StreamProvider<Show>(
            create: (context) =>
                CurrentShowStream(schedules: schedules, shows: show)
                    .currentShow,
            child: child,
          ),
        )
      ],
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
            headline4: GoogleFonts.arvo(
              fontWeight: FontWeight.bold,
              fontSize: 32,
              shadows: [
                Shadow(offset: Offset(0, 4)),
              ],
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
