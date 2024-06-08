import 'dart:async';

import 'package:flutter/cupertino.dart' as cup;

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:player/generated/l10n.dart';
import 'package:player/screens/now_playing_screen.dart';
import 'package:player/services/on_demand_api.dart';
import 'package:player/services/wp_schedule_api.dart';
import 'package:player/store/app_state.dart';
import 'package:player/store/audio/audio_actions.dart';
import 'package:player/store/history/history_item.dart';
import 'package:player/store/history/history_selectors.dart';
import 'package:player/store/on_demand_programs/on_demand_selectors.dart';
import 'package:player/store/schedules/schedules_selectors.dart';
import 'package:player/widgets/show_listing.dart';
import 'package:redux_entity/redux_entity.dart';

class _HistoryVM {
  const _HistoryVM({
    this.item,
    this.show,
    this.episode,
    required this.playing,
    this.removeItem,
  });

  final HistoryItem? item;
  final OnDemandEpisode? episode;
  final Show? show;
  final bool playing;

  final VoidCallback? removeItem;
}

class AllInOneTab extends StatefulWidget {
  AllInOneTab({
    required this.playLive,
    required this.openShow,
    required this.onRefresh,
  });
  final VoidCallback playLive;
  final ValueChanged<Show> openShow;
  final RefreshCallback onRefresh;

  @override
  _AllInOneTabState createState() => _AllInOneTabState();
}

class _AllInOneTabState extends State<AllInOneTab> {
  late Timer refresher;

  @override
  void initState() {
    refresher = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() {
    refresher.cancel();
    super.dispose();
  }

  resumeEpisode(_HistoryVM e) {
    StoreProvider.of<AppState>(context).dispatch(RequestPlayEpisode(
      episode: e.episode!,
      show: e.show!,
      position: e.item!.position,
    ));

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NowPlayingScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Theme.of(context).colorScheme.onBackground,
      onRefresh: widget.onRefresh,
      child: CustomScrollView(
        slivers: [
          SliverPadding(padding: EdgeInsets.only(top: 8)),
          SliverToBoxAdapter(
            child: Text(
              S.of(context).listenLive,
              style: Theme.of(context).textTheme.headline3,
            ),
          ),
          SliverToBoxAdapter(
            child: StoreConnector<AppState, Show?>(
              converter: (store) {
                final currentShowId = getCurrentShowId(store.state);
                if (currentShowId != null) {
                  return store.state.shows.entities[currentShowId];
                }
                return null;
              },
              builder: (context, show) => show != null
                  ? ShowListing.fromShow(
                      show,
                      onTap: widget.playLive,
                      heroTag: 'live',
                    )
                  : ShowListing(
                      title: S.of(context).defaultLiveShowName,
                      onTap: widget.playLive,
                      heroTag: 'live',
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: StoreConnector<AppState, _HistoryVM>(
              converter: (store) {
                final item = getLatestPlayable(store.state);
                if (item == null) {
                  return _HistoryVM(
                    playing: store.state.audio.state?.playing ?? false,
                  );
                }
                final show = store.state.shows.entities[item.showId];
                final episode = store.state.onDemandEpisodes
                    .entities[show!.onDemandShowId.replaceAll('-', '+')]
                    ?.where((element) => element.date == item.episodeDate)
                    .first;
                return _HistoryVM(
                  item: item,
                  show: show,
                  episode: episode,
                  playing: store.state.audio.state?.playing ?? false,
                  removeItem: () =>
                      store.dispatch(DeleteOne<HistoryItem>(item.id)),
                );
              },
              builder: (context, snapshot) => !snapshot.playing &&
                      snapshot.show != null &&
                      snapshot.episode != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 32.0),
                          child: Text(
                            S.of(context).jumpBackIn,
                            style: Theme.of(context).textTheme.headline3,
                          ),
                        ),
                        ShowListing(
                          title:
                              '${snapshot.show!.title.text} - ${snapshot.item!.episodeDate}',
                          thumbnail: snapshot.show!.thumbnail is String
                              ? snapshot.show!.thumbnail
                              : null,
                          subtitle:
                              '${snapshot.item!.position.format()} / ${snapshot.item!.showLength.format()}',
                          heroTag: snapshot.item!.id,
                          onTap: () => resumeEpisode(snapshot),
                          action: Material(
                            type: MaterialType.transparency,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(200),
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.black.withAlpha(100),
                                    Colors.black.withAlpha(0),
                                  ],
                                  center: Alignment.center,
                                ),
                              ),
                              child: IconButton(
                                icon: Icon(Icons.close),
                                onPressed: snapshot.removeItem,
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  : Container(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 32),
              child: Text(
                S.of(context).onDemand,
                style: Theme.of(context).textTheme.headline3,
              ),
            ),
          ),
          StoreConnector<AppState, List<Show>>(
            converter: (store) => getShowsForOnDemandStreaming(store.state),
            builder: (context, snapshot) => snapshot.isNotEmpty
                ? SliverGrid(
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      childAspectRatio: 3,
                      maxCrossAxisExtent: 600,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => ShowListing.fromShow(
                        snapshot[index],
                        heroTag: snapshot[index].slug,
                        onTap: () => widget.openShow(
                          snapshot[index],
                        ),
                      ),
                      childCount: snapshot.length,
                    ),
                  )
                : SliverToBoxAdapter(child: cup.CupertinoActivityIndicator()),
          ),
          SliverPadding(padding: EdgeInsets.all(48))
        ],
      ),
    );
  }
}
