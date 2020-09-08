import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:player/services/wp_schedule_api.dart';

class ShowDetailsScreen extends StatelessWidget {
  ShowDetailsScreen({this.show});

  final Show show;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                show.title.text,
                style: TextStyle(shadows: [
                  Shadow(color: Colors.black, offset: Offset(0, 2))
                ]),
              ),
              background: Hero(
                tag: show.slug,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: show.thumbnail,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [
                              Colors.black.withAlpha(0),
                              Colors.black.withAlpha(140),
                            ],
                            stops: [
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
        ],
      ),
    );
  }
}
