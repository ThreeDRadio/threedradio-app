import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:just_audio/just_audio.dart';
import 'package:player/screens/all_in_one_tab.dart';
import 'package:player/screens/now_playing_screen.dart';
import 'package:player/screens/show_detail_screen.dart';
import 'package:player/services/on_demand_api.dart';
import 'package:player/services/wp_schedule_api.dart';
import 'package:player/store/app_state.dart';
import 'package:player/store/audio/audio_actions.dart';
import 'package:player/widgets/now_playing_bar.dart';
import 'package:redux_entity/redux_entity.dart';

class _NowPlayingBarData {
  _NowPlayingBarData({
    this.item,
    this.state,
  });

  final MediaItem item;
  final PlaybackState state;
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  @override
  initState() {
    super.initState();
  }

  @override
  didChangeDependencies() {
    final store = StoreProvider.of<AppState>(context);
    store.dispatch(RequestRetrieveAll<Schedule>());
    store.dispatch(RequestRetrieveAll<Show>());
    store.dispatch(RequestRetrieveAll<OnDemandProgram>());
    super.didChangeDependencies();
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
        title: Text('Three D Radio'),
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
                ),
              ),
            ),
            Flexible(
              flex: 0,
              child: AnimatedSize(
                duration: const Duration(milliseconds: 200),
                vsync: this,
                curve: Curves.easeInOut,
                child: StoreConnector<AppState, _NowPlayingBarData>(
                  converter: (store) => _NowPlayingBarData(
                    item: store.state.audio.currentItem,
                    state: store.state.audio.state,
                  ),
                  builder: (context, snapshot) {
                    final state = snapshot?.state?.processingState ??
                        AudioProcessingState.none;
                    if (state != AudioProcessingState.stopped &&
                        state != AudioProcessingState.none) {
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
