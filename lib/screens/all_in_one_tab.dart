import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:player/generated/l10n.dart';
import 'package:player/services/wp_schedule_api.dart';
import 'package:player/store/app_state.dart';
import 'package:player/store/on_demand_programs/on_demand_selectors.dart';
import 'package:player/store/schedules/schedules_selectors.dart';
import 'package:player/widgets/show_listing.dart';

class AllInOneTab extends StatefulWidget {
  AllInOneTab({
    required this.playLive,
    required this.openShow,
  });
  final VoidCallback playLive;
  final ValueChanged<Show> openShow;

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

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
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
            builder: (context, show) => ShowListing(
              data: show,
              onTap: widget.playLive,
              heroTag: 'live',
            ),
          ),
        ),
        SliverPadding(padding: EdgeInsets.only(top: 32)),
        SliverToBoxAdapter(
          child: Text(
            S.of(context).onDemand,
            style: Theme.of(context).textTheme.headline3,
          ),
        ),
        StoreConnector<AppState, List<Show>>(
          converter: (store) => getShowsForOnDemandStreaming(store.state),
          builder: (context, snapshot) => snapshot.isNotEmpty
              ? SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => ShowListing(
                      data: snapshot[index],
                      heroTag: snapshot[index].slug,
                      onTap: () => widget.openShow(
                        snapshot[index],
                      ),
                    ),
                    childCount: snapshot.length,
                  ),
                )
              : SliverToBoxAdapter(child: CupertinoActivityIndicator()),
        ),
        SliverPadding(padding: EdgeInsets.all(48))
      ],
    );
  }
}
