import 'package:flutter/material.dart';
import 'package:player/services/wp_schedule_api.dart';
import 'package:player/widgets/show_detail_header.dart';
import 'package:provider/provider.dart';

class LiveBroadcastTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final show = Provider.of<Show>(context);
    return ListView(
      children: [
        ShowDetailHeader(
          title: show.title.rendered,
          subtitle: show.meta.subtitle2.first,
          imageUrl: show.thumbnail,
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(show.meta.show_incipit.first),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 48.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RaisedButton(
                onPressed: () {},
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
