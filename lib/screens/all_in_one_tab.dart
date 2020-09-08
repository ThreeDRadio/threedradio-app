import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:player/screens/show_list_tab.dart';
import 'package:player/services/on_demand_api.dart';
import 'package:player/services/wp_schedule_api.dart';
import 'package:player/widgets/show_listing.dart';
import 'package:provider/provider.dart';

class AllInOneTab extends StatefulWidget {
  AllInOneTab({
    this.playLive,
    this.openShow,
  });
  final VoidCallback playLive;
  final ValueChanged<Show> openShow;

  @override
  _AllInOneTabState createState() => _AllInOneTabState();
}

class _AllInOneTabState extends State<AllInOneTab> {
  @override
  void didChangeDependencies() {
    shows = getShowsForStreaming();
    super.didChangeDependencies();
  }

  Future<List<OnDemandShow>> getShowsForStreaming() async {
    final onDemand =
        await Provider.of<OnDemandApiService>(context, listen: false)
            .getOnDemandPrograms();
    final shows =
        await Provider.of<WpScheduleApiService>(context, listen: false)
            .getShows();

    final showsMap = shows
        .asMap()
        .map((key, value) => MapEntry<String, Show>(value.slug, value));

    return onDemand
        .map((e) => OnDemandShow(onDemand: e, show: showsMap[e.slug]))
        .where((element) => element.show != null)
        .toList()
          ..sort((a, b) => a.show.title.text.compareTo(b.show.title.text));
  }

  Future<List<OnDemandShow>> shows;
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(padding: EdgeInsets.only(top: 8)),
        SliverToBoxAdapter(
          child: Text(
            'Listen Live',
            style: Theme.of(context).textTheme.headline3,
          ),
        ),
        SliverToBoxAdapter(
          child: ShowListing(
            data: Provider.of<Show>(context),
            onTap: widget.playLive,
            heroTag: 'live',
          ),
        ),
        SliverPadding(padding: EdgeInsets.only(top: 32)),
        SliverToBoxAdapter(
          child: Text(
            'On Demand',
            style: Theme.of(context).textTheme.headline3,
          ),
        ),
        FutureBuilder<List<OnDemandShow>>(
          future: shows,
          builder: (context, snapshot) => snapshot.hasData
              ? SliverList(
                  delegate: SliverChildBuilderDelegate(
                  (context, index) => ShowListing(
                    data: snapshot.data[index].show,
                    heroTag: snapshot.data[index].show.slug,
                    onTap: () => widget.openShow(
                      snapshot.data[index].show,
                    ),
                  ),
                ))
              : SliverToBoxAdapter(
                  child: CupertinoActivityIndicator(),
                ),
        )
      ],
    );
  }
}
