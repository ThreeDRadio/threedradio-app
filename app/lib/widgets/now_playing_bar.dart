import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NowPlayingBar extends StatelessWidget {
  NowPlayingBar({
    this.state,
    this.item,
    required this.onPause,
    required this.onPlay,
    required this.onStop,
  });

  final MediaItem? item;
  final PlaybackState? state;

  final VoidCallback onPause;
  final VoidCallback onPlay;
  final VoidCallback onStop;
  @override
  Widget build(BuildContext context) {
    return IconTheme(
      data: IconThemeData(color: Color(0xfff2ebda)),
      child: DefaultTextStyle(
        style: TextStyle(color: Color(0xfff2ebda)),
        child: Container(
          color: Colors.black,
          child: SafeArea(
            child: Container(
              height: 70,
              color: Colors.black,
              child: Row(
                children: [
                  if (item?.artUri != null)
                    AspectRatio(
                      aspectRatio: 1,
                      child: CachedNetworkImage(
                        imageUrl: item!.artUri.toString(),
                        fit: BoxFit.cover,
                      ),
                    ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item?.title.toUpperCase() ?? '',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  inherit: true,
                                  color: Color(0xfff2ebda),
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (item?.album != null) Text(item!.album!),
                        ],
                      ),
                    ),
                  ),
                  if (state != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children:
                          state!.processingState ==
                              AudioProcessingState.buffering
                          ? [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: CupertinoActivityIndicator(),
                              ),
                            ]
                          : [
                              if (state!.controls
                                  .map((c) => c.action)
                                  .contains(MediaAction.pause))
                                IconButton(
                                  icon: Icon(Icons.pause),
                                  onPressed: onPause,
                                ),
                              if (state!.controls
                                  .map((e) => e.action)
                                  .contains(MediaAction.play))
                                IconButton(
                                  icon: Icon(Icons.play_arrow),
                                  onPressed: onPlay,
                                ),
                              if (state!.controls
                                  .map((e) => e.action)
                                  .contains(MediaAction.stop))
                                IconButton(
                                  icon: Icon(Icons.stop),
                                  onPressed: onStop,
                                ),
                            ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
