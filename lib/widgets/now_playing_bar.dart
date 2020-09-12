import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class NowPlayingBar extends StatelessWidget {
  NowPlayingBar({
    this.state,
    this.item,
    this.onPause,
    this.onPlay,
    this.onStop,
  });

  final MediaItem item;
  final PlaybackState state;

  final VoidCallback onPause;
  final VoidCallback onPlay;
  final VoidCallback onStop;
  @override
  Widget build(BuildContext context) {
    return Container(
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
                    imageUrl: item.artUri,
                    fit: BoxFit.cover,
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item?.title ?? '',
                        style: Theme.of(context).textTheme.headline6,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (item?.album != null) Text(item.album),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (state.actions.contains(MediaAction.pause))
                    IconButton(icon: Icon(Icons.pause), onPressed: onPause),
                  if (state.actions.contains(MediaAction.play))
                    IconButton(icon: Icon(Icons.play_arrow), onPressed: onPlay),
                  if (state.actions.contains(MediaAction.stop))
                    IconButton(icon: Icon(Icons.stop), onPressed: onStop)
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
