import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:player/providers/shows_provider.dart';
import 'package:player/services/on_demand_api.dart';
import 'package:player/services/wp_schedule_api.dart';
import 'package:provider/provider.dart';

class OnDemandShow {
  const OnDemandShow({this.onDemand, this.show});
  final OnDemandProgram onDemand;
  final Show show;
}

class ShowListTab extends StatefulWidget {
  @override
  _ShowListTabState createState() => _ShowListTabState();
}

class _ShowListTabState extends State<ShowListTab> {
  @override
  void initState() {
    super.initState();
  }

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
    return FutureBuilder<List<OnDemandShow>>(
      future: shows,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: OnDemandShowListing(data: snapshot.data[index]),
            ),
          );
        } else {
          return Center(
            child: CupertinoActivityIndicator(),
          );
        }
      },
    );
  }
}

class OnDemandShowListing extends StatelessWidget {
  const OnDemandShowListing({
    @required this.data,
    Key key,
  }) : super(key: key);

  final OnDemandShow data;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: AspectRatio(
        aspectRatio: 3,
        child: Stack(
          children: [
            if (data.show.thumbnail is String)
              AspectRatio(
                aspectRatio: 3,
                child: CachedNetworkImage(
                  imageUrl: data.show.thumbnail,
                  fit: BoxFit.cover,
                  color: Colors.black.withAlpha(100),
                  colorBlendMode: BlendMode.multiply,
                ),
              ),
            Container(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.show.title.text ?? '',
                    style: Theme.of(context).textTheme.headline5.copyWith(
                      shadows: [
                        Shadow(offset: Offset(0, 4)),
                      ],
                    ),
                  ),
                  if (data.show.meta.subtitle2 != null)
                    Text(
                      data.show.meta.subtitle2[0],
                      style: Theme.of(context).textTheme.bodyText2.copyWith(
                        shadows: [
                          Shadow(offset: Offset(0, 4)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
