import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:player/audio/audio_start_params.dart';
import 'package:player/audio/background_task.dart';
import 'package:player/environment/environment.dart';
import 'package:player/screens/live_broadcast_tab.dart';
import 'package:player/services/wp_schedule_api.dart';
import 'package:player/widgets/now_playing_bar.dart';
import 'package:player/widgets/show_detail_header.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  @override
  TabController tabController;
  initState() {
    tabController = TabController(
      length: 2,
      vsync: this,
    );
    super.initState();
  }

  startLiveStream() async {
    final currentShow = Provider.of<Show>(context, listen: false);
    await AudioService.start(
      backgroundTaskEntrypoint: backgroundTaskEntrypoint,
      params: AudioStartParams(
        mode: PlaybackMode.live,
        url: THREE_D_RADIO_STREAM,
      ).toJson(),
    );
    await AudioService.updateMediaItem(
      MediaItem(
        title: currentShow.title.text,
        artUri: currentShow.thumbnail,
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
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.radio),
            title: Text('Live'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.offline_bolt),
            title: Text('On Demand'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              children: [
                LiveBroadcastTab(onPlay: startLiveStream),
              ],
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
    );
  }
}
