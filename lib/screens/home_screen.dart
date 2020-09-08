import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:player/audio/audio_start_params.dart';
import 'package:player/audio/background_task.dart';
import 'package:player/environment/environment.dart';
import 'package:player/screens/all_in_one_tab.dart';
import 'package:player/screens/live_broadcast_tab.dart';
import 'package:player/screens/show_list_tab.dart';
import 'package:player/services/wp_schedule_api.dart';
import 'package:player/widgets/now_playing_bar.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  @override
  initState() {
    super.initState();
  }

  int currentIndex = 0;
  PageController pageController = PageController(initialPage: 0);

  changePage(int index) {
    pageController.animateToPage(index,
        duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
    setState(() {
      currentIndex = index;
    });
  }

  startLiveStream() async {
    final currentShow = Provider.of<Show>(context, listen: false);
    await AudioService.start(
      backgroundTaskEntrypoint: backgroundTaskEntrypoint,
      androidNotificationIcon: 'drawable/ic_threedradio',
      params: AudioStartParams(
        mode: PlaybackMode.live,
        url: Environment.liveStreamUrl,
      ).toJson(),
    );
    await AudioService.updateMediaItem(
      MediaItem(
        title: currentShow?.title?.text ?? 'Three D Radio',
        artUri:
            currentShow?.thumbnail is String ? currentShow?.thumbnail : null,
        album: 'Three D Radio - Live',
        id: 'LIVE',
      ),
    );
    await AudioService.play();
  }

  pause() async {
    return AudioService.pause();
  }

  resume() async {
    return AudioService.play();
  }

  stop() async {
    return AudioService.stop();
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
                ),
              ),
            ),
            Flexible(
              flex: 0,
              child: AnimatedSize(
                duration: const Duration(milliseconds: 200),
                vsync: this,
                curve: Curves.easeInOut,
                child: StreamBuilder<MediaItem>(
                  stream: AudioService.currentMediaItemStream,
                  builder: (context, mediaItemSnapshot) =>
                      StreamBuilder<PlaybackState>(
                    stream: AudioService.playbackStateStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData &&
                          snapshot.data.processingState !=
                              AudioProcessingState.stopped &&
                          snapshot.data.processingState !=
                              AudioProcessingState.none) {
                        return NowPlayingBar(
                          item: mediaItemSnapshot.data,
                          state: snapshot.data,
                          onPause: pause,
                          onPlay: resume,
                          onStop: stop,
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
