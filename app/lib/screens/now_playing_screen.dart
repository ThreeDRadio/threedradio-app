import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:player/generated/l10n.dart';
import 'package:player/services/wp_schedule_api.dart';
import 'package:player/store/app_state.dart';
import 'package:player/store/audio/audio_actions.dart';

extension FormatDuration on Duration {
  String format() {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(inSeconds.remainder(60));
    return "${twoDigits(inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}

class _ViewModel {
  const _ViewModel({
    this.item,
    this.state,
    this.show,
    this.controls = const [],
    required this.seekToPosition,
  });

  final MediaItem? item;
  final Show? show;
  final PlaybackState? state;
  final List<MediaAction> controls;
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
  late double seekingPosition;

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

  pause() async {
    StoreProvider.of<AppState>(context).dispatch(RequestPause());
  }

  resume() async {
    StoreProvider.of<AppState>(context).dispatch(RequestResume());
  }

  stop() async {
    StoreProvider.of<AppState>(context).dispatch(RequestStop());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      converter: (store) => _ViewModel(
        item: store.state.audio.currentItem,
        state: store.state.audio.state,
        controls:
            store.state.audio.state?.controls.map((e) => e.action).toList() ??
                [],
        show: store.state.shows.entities[
            (store.state.audio.currentItem?.extras ?? const {})['showId']
                ?.toString()],
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
                      snapshot.item?.title ?? '',
                      style: TextStyle(shadows: [
                        Shadow(
                          color: Colors.black,
                          offset: Offset(0, 2),
                        )
                      ]),
                    ),
                  ),
                  background: Hero(
                    tag: snapshot.item?.id ?? "on demand",
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (snapshot.item?.artUri != null)
                          CachedNetworkImage(
                            imageUrl: snapshot.item!.artUri.toString(),
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
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (snapshot.controls.contains(MediaAction.rewind))
                            IconButton(
                              icon: Icon(Icons.replay_30),
                              onPressed: snapshot.state!.position >
                                      const Duration(seconds: 30)
                                  ? () => snapshot.seekToPosition(
                                      snapshot.state!.position -
                                          const Duration(seconds: 30))
                                  : null,
                              iconSize: 48,
                            )
                          else
                            IconButton(
                              icon: Icon(Icons.replay_30),
                              onPressed: null,
                              iconSize: 48,
                            ),
                          if (snapshot.controls
                              .contains(MediaAction.fastForward))
                            IconButton(
                              icon: Icon(Icons.forward_30),
                              onPressed:
                                  (snapshot.item?.duration ?? Duration.zero) -
                                              snapshot.state!.position >
                                          const Duration(seconds: 30)
                                      ? () => snapshot.seekToPosition(
                                          snapshot.state!.position +
                                              const Duration(seconds: 30))
                                      : null,
                              iconSize: 48,
                            )
                          else
                            IconButton(
                              icon: Icon(Icons.forward_30),
                              onPressed: null,
                              iconSize: 48,
                            ),
                          if (snapshot.controls.contains(MediaAction.pause))
                            IconButton(
                              icon: Icon(Icons.pause),
                              onPressed: pause,
                              iconSize: 48,
                            ),
                          if (snapshot.controls.contains(MediaAction.play))
                            IconButton(
                              icon: Icon(Icons.play_arrow),
                              onPressed: resume,
                              iconSize: 48,
                            ),
                          if (!(snapshot.controls.contains(MediaAction.play)) &&
                              !(snapshot.controls.contains(MediaAction.pause)))
                            IconButton(
                              icon: Icon(Icons.play_arrow),
                              iconSize: 48,
                              onPressed: null,
                            ),
                          if (snapshot.controls.contains(MediaAction.stop))
                            IconButton(
                              icon: Icon(Icons.stop),
                              onPressed: stop,
                              iconSize: 48,
                            )
                          else
                            IconButton(
                              icon: Icon(Icons.stop),
                              onPressed: null,
                              iconSize: 48,
                            ),
                        ],
                      ),
                    ),
                    if ((snapshot.item?.duration ?? Duration.zero) >
                        Duration.zero)
                      Slider(
                        min: 0,
                        max: snapshot.item!.duration!.inSeconds.toDouble(),
                        value: seekInProgress
                            ? seekingPosition
                            : snapshot.state!.position.inSeconds.toDouble(),
                        onChangeStart: onSeekStart,
                        onChangeEnd: (value) {
                          setState(() {
                            seekInProgress = false;
                            snapshot.seekToPosition(
                                Duration(seconds: value.round()));
                          });
                        },
                        onChanged: (value) {
                          setState(() {
                            seekingPosition = value;
                          });
                        },
                      ),
                    if ((snapshot.item?.duration ?? Duration.zero) >
                        Duration.zero)
                      if (seekInProgress)
                        Text(
                            '${Duration(seconds: seekingPosition.round()).format()} / ${snapshot.item!.duration!.format()}')
                      else
                        Text(
                            '${snapshot.state!.position.format()} / ${snapshot.item!.duration!.format()}')
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
                      ? Html(data: snapshot.show!.content.rendered)
                      : Html(
                          data: snapshot.show?.meta.show_incipit?.isNotEmpty ==
                                  true
                              ? snapshot.show!.meta.show_incipit![0]
                              : S.of(context).defaultShortDescription),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
