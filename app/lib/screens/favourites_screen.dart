import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:player/generated/l10n.dart';
import 'package:player/screens/show_detail_screen.dart';
import 'package:player/services/wp_schedule_api.dart';
import 'package:player/store/app_state.dart';
import 'package:player/store/favourites/favourites_selectors.dart';
import 'package:player/widgets/show_listing.dart';

class FavouritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).favourites)),
      body: SafeArea(
        child: StoreConnector<AppState, List<Show>>(
            converter: (store) => getFavouritesShows(store.state),
            builder: (context, snapshot) => snapshot.isNotEmpty
                ? ListView.builder(
                    padding: EdgeInsets.all(8),
                    itemBuilder: (context, index) => ShowListing.fromShow(
                      snapshot[index],
                      heroTag: snapshot[index].slug,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                ShowDetailsScreen(show: snapshot[index]),
                            fullscreenDialog: true,
                          ),
                        );
                      },
                    ),
                    itemCount: snapshot.length,
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32.0),
                        child: Icon(
                          Icons.star_outline,
                          size: 220,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        S.of(context).favouritesEmpty,
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(S.of(context).favouritesEmptyBody),
                      )
                    ],
                  )),
      ),
    );
  }
}
