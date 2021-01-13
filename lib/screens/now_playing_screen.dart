import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:player/services/on_demand_api.dart';
import 'package:player/services/wp_schedule_api.dart';
import 'package:player/store/app_state.dart';
import 'package:player/store/audio/audio_actions.dart';

class _ViewModel {
  const _ViewModel({
    this.item,
    this.state,
    this.show,
    this.seekToPosition,
  });

  final MediaItem item;
  final Show show;
  final PlaybackState state;
  final ValueChanged<Duration> seekToPosition;
}

class NowPlayingScreen extends StatefulWidget {
  NowPlayingScreen({
    this.fadeInDelay = const Duration(milliseconds: 300),
    this.fadeInDuration = const Duration(milliseconds: 300),
  });

  final Duration fadeInDelay;
  final Duration fadeInDuration;
  @override
  _NowPlayingScreenState createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  bool transitionComplete = false;
  bool seekInProgress = false;
  double seekingPosition;

  void initState() {
    Future.delayed(widget.fadeInDelay, () {
      if (mounted) {
        setState(() {
          transitionComplete = true;
        });
      }
    });
    super.initState();
  }

  onSeekStart(double value) {
    setState(() {
      seekInProgress = true;
      seekingPosition = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      converter: (store) => _ViewModel(
        item: store.state.audio.currentItem,
        state: store.state.audio.state,
        show: store.state.shows.entities[
            store.state.audio.currentItem.extras['showId'].toString()],
        seekToPosition: (Duration position) {
          store.dispatch(RequestSeek(position));
        },
      ),
      builder: (context, snapshot) => Scaffold(
        body: SafeArea(
          top: false,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: AnimatedOpacity(
                    duration: widget.fadeInDuration,
                    opacity: transitionComplete ? 1 : 0,
                    child: Text(
                      snapshot.item.title,
                      style: TextStyle(shadows: [
                        Shadow(
                          color: Colors.black,
                          offset: Offset(0, 2),
                        )
                      ]),
                    ),
                  ),
                  background: Hero(
                    tag: snapshot.item.id ?? "on demand",
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (snapshot.item.artUri != null)
                          CachedNetworkImage(
                            imageUrl: snapshot.item.artUri,
                            fit: BoxFit.cover,
                          ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [
                                  Colors.black.withAlpha(140),
                                  Colors.black.withAlpha(0),
                                  Colors.black.withAlpha(0),
                                  Colors.black.withAlpha(140),
                                ],
                                stops: [
                                  0,
                                  0.4,
                                  0.6,
                                  1.0
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Row(children: [Text('Buttons')]),
                    Slider(
                      min: 0,
                      max: snapshot.item.duration.inSeconds.toDouble(),
                      value: seekInProgress
                          ? seekingPosition
                          : snapshot.state.currentPosition.inSeconds.toDouble(),
                      onChangeStart: onSeekStart,
                      onChangeEnd: (value) {
                        setState(() {
                          seekInProgress = false;
                          snapshot
                              .seekToPosition(Duration(seconds: value.round()));
                        });
                      },
                      onChanged: (value) {
                        setState(() {
                          seekingPosition = value;
                        });
                      },
                    ),
                    Text(
                        '${snapshot.state.currentPosition} / ${snapshot.item.duration}')
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 32,
                  ),
                  child: snapshot.show?.content?.text?.isNotEmpty ?? false
                      ? Html(data: snapshot.show.content.rendered)
                      : Html(
                          data: snapshot.show?.meta?.show_incipit?.isNotEmpty ==
                                  true
                              ? snapshot.show.meta.show_incipit[0]
                              : 'All The Hits'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
