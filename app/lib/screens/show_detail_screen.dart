import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:player/generated/l10n.dart';
import 'package:player/screens/now_playing_screen.dart';
import 'package:player/services/new_api/dto/show_dto.dart';
import 'package:player/services/on_demand_api.dart';
import 'package:player/store/app_state.dart';
import 'package:player/store/audio/audio_actions.dart';
import 'package:player/store/favourites/favourites_actions.dart';
import 'package:player/store/on_demand_programs/on_demand_selectors.dart';
import 'package:player/widgets/days_left_badge.dart';
import 'package:player/widgets/separator.dart';
import 'package:redux_entity/redux_entity.dart';

class _FaveMV {
  const _FaveMV({
    required this.isFavourite,
    required this.addToFavourites,
    required this.removeFromFavourites,
  });

  final bool isFavourite;
  final VoidCallback addToFavourites;
  final VoidCallback removeFromFavourites;
}

class ShowDetailsScreen extends StatefulWidget {
  const ShowDetailsScreen({
    super.key,
    required this.show,
    this.fadeInDelay = const Duration(milliseconds: 300),
    this.fadeInDuration = const Duration(milliseconds: 300),
  });

  final ShowDto show;
  final Duration fadeInDelay;
  final Duration fadeInDuration;

  @override
  State createState() => _ShowDetailsScreenState();
}

class _ShowDetailsScreenState extends State<ShowDetailsScreen> {
  bool transitionComplete = false;

  @override
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
      RequestRetrieveOne<List<OnDemandEpisode>>(widget.show.onDemandShowId),
    );
    super.didChangeDependencies();
  }

  void playEpisode(OnDemandEpisode e) {
    StoreProvider.of<AppState>(
      context,
    ).dispatch(RequestPlayEpisode(episode: e, show: widget.show));

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
              centerTitle: false,
              expandedHeight: 220,
              collapsedHeight: 220,
              pinned: true,
              actions: [
                StoreConnector<AppState, _FaveMV>(
                  converter: (store) => _FaveMV(
                    isFavourite: store.state.favourites.entities.containsKey(
                      widget.show.id.toString(),
                    ),
                    addToFavourites: () => store.dispatch(
                      CreateOne<Favourite>(
                        Favourite(showId: widget.show.id.toString()),
                      ),
                    ),
                    removeFromFavourites: () => store.dispatch(
                      DeleteOne<Favourite>(widget.show.id.toString()),
                    ),
                  ),
                  builder: (context, vm) {
                    return IconButton(
                      icon: vm.isFavourite
                          ? Icon(Icons.star)
                          : Icon(Icons.star_border),
                      onPressed: vm.isFavourite
                          ? vm.removeFromFavourites
                          : vm.addToFavourites,
                    );
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: false,
                titlePadding: EdgeInsets.all(8),
                title: AnimatedOpacity(
                  duration: widget.fadeInDuration,
                  opacity: transitionComplete ? 1 : 0,
                  child: Container(
                    color: Colors.black,
                    padding: EdgeInsets.only(
                      left: 6,
                      right: 6,
                      top: 1,
                      bottom: 6,
                    ),
                    child: Text(
                      HtmlUnescape().convert(
                        widget.show.name.toUpperCase(),
                      ),
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Color(0xfff2ebda),
                          ),
                    ),
                  ),
                ),
                background: Hero(
                  tag: widget.show.slug,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (widget.show.acf?.program_featured_image?.medium
                          is String)
                        CachedNetworkImage(
                          imageUrl:
                              widget.show.acf!.program_featured_image!.medium!,
                          fit: BoxFit.cover,
                        ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withAlpha(150),
                              Colors.black.withAlpha(0),
                            ],
                            stops: [
                              0.2,
                              0.6,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
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
                child: widget.show.acf?.show_excerpt?.isNotEmpty ?? false
                    ? Html(data: widget.show.acf!.show_excerpt)
                    : Html(data: S.of(context).defaultShortDescription),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.only(left: 8, bottom: 8),
              sliver: SliverToBoxAdapter(
                child: Separator(
                  child: Text(S.of(context).onDemandEpisodes.toUpperCase()),
                ),
              ),
            ),
            StoreConnector<AppState, List<OnDemandEpisode>>(
              converter: (store) =>
                  getEpisodesForShow(store.state, widget.show),
              builder: (context, episodes) {
                if (episodes.isEmpty) {
                  return SliverToBoxAdapter(
                    child: CupertinoActivityIndicator(),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(2),
                        ),
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
                                      Text(
                                        episodes[index].date,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge,
                                      ),
                                      Text(
                                        '${(episodes[index].size / 1024 / 2014).round()}mb',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                if (DateTime.now()
                                        .difference(
                                          DateTime.parse(episodes[index].date),
                                        )
                                        .inDays >
                                    21)
                                  DaysLeftBadge(
                                    showDate: DateTime.parse(
                                      episodes[index].date,
                                    ),
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
              },
            ),
          ],
        ),
      ),
    );
  }
}
