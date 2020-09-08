import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:player/services/wp_schedule_api.dart';
import 'package:player/widgets/show_detail_header.dart';
import 'package:provider/provider.dart';

class LiveBroadcastTab extends StatelessWidget {
  const LiveBroadcastTab({this.onPlay});

  final VoidCallback onPlay;
  @override
  Widget build(BuildContext context) {
    final show = Provider.of<Show>(context);
    return ListView(
      children: [
        if (show != null)
          ShowDetailHeader(
            title: show.title.text,
            subtitle: show.meta?.subtitle2?.first ?? '',
            imageUrl: show.thumbnail,
          ),
        if (show == null)
          ShowDetailHeader(
            title: 'Three D Blend',
            subtitle: 'All the hits',
          ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
              HtmlUnescape().convert(show?.meta?.show_incipit?.first) ?? ''),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 48.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RaisedButton(
                onPressed: onPlay,
                child: Row(
                  children: [
                    Icon(Icons.play_arrow),
                    Text('Listen Now'.toUpperCase()),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
