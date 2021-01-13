import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:player/screens/now_playing_screen.dart';
import 'package:player/services/on_demand_api.dart';
import 'package:player/services/wp_schedule_api.dart';
import 'package:player/store/app_state.dart';
import 'package:player/store/audio/audio_actions.dart';
import 'package:redux_entity/redux_entity.dart';

class ShowDetailsScreen extends StatefulWidget {
  ShowDetailsScreen(
      {this.show,
      this.fadeInDelay = const Duration(milliseconds: 300),
      this.fadeInDuration = const Duration(milliseconds: 300)});

  final Show show;
  final Duration fadeInDelay;
  final Duration fadeInDuration;

  @override
  _ShowDetailsScreenState createState() => _ShowDetailsScreenState();
}

class _ShowDetailsScreenState extends State<ShowDetailsScreen> {
  bool transitionComplete = false;
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

  @override
  void didChangeDependencies() {
    StoreProvider.of<AppState>(context).dispatch(
        RequestRetrieveOne<List<OnDemandEpisode>>(widget.show.onDemandShowId));
    super.didChangeDependencies();
  }

  playEpisode(OnDemandEpisode e) {
    StoreProvider.of<AppState>(context)
        .dispatch(RequestPlayEpisode(episode: e));

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => NowPlayingScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    widget.show.title.text,
                    style: TextStyle(shadows: [
                      Shadow(
                        color: Colors.black,
                        offset: Offset(0, 2),
                      )
                    ]),
                  ),
                ),
                background: Hero(
                  tag: widget.show.slug,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (widget?.show?.thumbnail != null)
                        CachedNetworkImage(
                          imageUrl: widget.show.thumbnail,
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
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 32,
                ),
                child: widget.show.content.text.isNotEmpty
                    ? Html(data: widget.show.content.rendered)
                    : Html(
                        data: widget.show.meta.show_incipit?.isNotEmpty == true
                            ? widget.show.meta.show_incipit[0]
                            : 'All The Hits'),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.only(left: 8, bottom: 8),
              sliver: SliverToBoxAdapter(
                  child: Text(
                'On Demand Episodes',
                style: Theme.of(context).textTheme.headline5,
              )),
            ),
            StoreConnector<AppState, List<OnDemandEpisode>>(
                converter: (store) =>
                    store.state.onDemandEpisodes
                        .entities[widget.show.onDemandShowId]?.reversed
                        ?.toList() ??
                    <OnDemandEpisode>[],
                builder: (context, episodes) {
                  if (episodes.isEmpty) {
                    return SliverToBoxAdapter(
                        child: CupertinoActivityIndicator());
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Card(
                          child: InkWell(
                            onTap: () => playEpisode(episodes[index]),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(Icons.play_arrow),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('${episodes[index].date}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline6),
                                        Text(
                                            (episodes[index].size / 1024 / 2014)
                                                    .round()
                                                    .toString() +
                                                'mb',
                                            style: Theme.of(context)
                                                .textTheme
                                                .caption)
                                      ],
                                    ),
                                  ),
                                  if (DateTime.now()
                                          .difference(DateTime.parse(
                                              episodes[index].date))
                                          .inDays >
                                      21)
                                    Chip(
                                      label: Text((28 -
                                                  DateTime.now()
                                                      .difference(
                                                          DateTime.parse(
                                                              episodes[index]
                                                                  .date))
                                                      .inDays)
                                              .toString() +
                                          ' Days Left'),
                                      labelStyle: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                      backgroundColor: Colors.amberAccent,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      childCount: episodes.length,
                    ),
                  );
                })
          ],
        ),
      ),
    );
  }
}
