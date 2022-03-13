import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:player/generated/l10n.dart';
import 'package:player/screens/all_in_one_tab.dart';
import 'package:player/screens/now_playing_screen.dart';
import 'package:player/screens/show_detail_screen.dart';
import 'package:player/services/on_demand_api.dart';
import 'package:player/services/wp_schedule_api.dart';
import 'package:player/store/app_selectors.dart';
import 'package:player/store/app_state.dart';
import 'package:player/store/audio/audio_actions.dart';
import 'package:player/widgets/now_playing_bar.dart';
import 'package:redux_entity/redux_entity.dart';

class _NowPlayingBarData {
  _NowPlayingBarData({
    this.item,
    this.state,
  });

  final MediaItem? item;
  final PlaybackState? state;
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool needToFetch = true;

  @override
  initState() {
    super.initState();
  }

  @override
  didChangeDependencies() {
    if (needToFetch) {
      initialFetch();
      needToFetch = false;
    }
    super.didChangeDependencies();
  }

  void initialFetch() {
    final store = StoreProvider.of<AppState>(context);
    store.dispatch(RequestRetrieveAll<Schedule>());
    store.dispatch(RequestRetrieveAll<Show>());
    store.dispatch(RequestRetrieveAll<OnDemandProgram>());
  }

  Future<void> refresh() {
    final store = StoreProvider.of<AppState>(context);
    store.dispatch(RequestRetrieveAll<Schedule>(forceRefresh: true));
    store.dispatch(RequestRetrieveAll<Show>(forceRefresh: true));
    store.dispatch(RequestRetrieveAll<OnDemandProgram>(forceRefresh: true));
    return store.onChange.firstWhere((state) => !somethingLoading(state));
  }

  openShowDetail(Show show) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ShowDetailsScreen(show: show),
        fullscreenDialog: true,
      ),
    );
  }

  startLiveStream() async {
    StoreProvider.of<AppState>(context).dispatch(RequestPlayLive());
  }

  pause() async {
    StoreProvider.of<AppState>(context).dispatch(RequestPause());
  }

  resume() async {
    StoreProvider.of<AppState>(context).dispatch(RequestResume());
  }

  stop() async {
    StoreProvider.of<AppState>(context).dispatch(RequestStop());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).appName),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            Stack(
              fit: StackFit.passthrough,
              children: [
                Image.asset(
                  'assets/images/header.png',
                  fit: BoxFit.fill,
                ),
                AspectRatio(
                  aspectRatio: 205.0 / 115.0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withAlpha(60),
                          Colors.black.withAlpha(120),
                          Colors.black.withAlpha(60)
                        ],
                        stops: [0, 0.5, 1],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        S.of(context).appName,
                        style: Theme.of(context)
                            .textTheme
                            .headline4!
                            .copyWith(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ListTile(
              leading: Icon(Icons.star),
              title: Text(S.of(context).favourites),
              onTap: () => Navigator.of(context).popAndPushNamed('/favourites'),
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text(S.of(context).about),
              onTap: () => Navigator.of(context).popAndPushNamed('/about'),
            )
          ],
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: AllInOneTab(
                  playLive: startLiveStream,
                  openShow: openShowDetail,
                  onRefresh: refresh,
                ),
              ),
            ),
            Flexible(
              flex: 0,
              child: AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: StoreConnector<AppState, _NowPlayingBarData>(
                  converter: (store) => _NowPlayingBarData(
                    item: store.state.audio.currentItem,
                    state: store.state.audio.state,
                  ),
                  builder: (context, snapshot) {
                    final state = snapshot.state?.processingState ??
                        AudioProcessingState.idle;
                    if (state != AudioProcessingState.completed &&
                        state != AudioProcessingState.idle) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => NowPlayingScreen(),
                              fullscreenDialog: true,
                            ),
                          );
                        },
                        child: NowPlayingBar(
                          item: snapshot.item,
                          state: snapshot.state,
                          onPause: pause,
                          onPlay: resume,
                          onStop: stop,
                        ),
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
