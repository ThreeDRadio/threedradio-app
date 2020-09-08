import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:player/providers/shows_provider.dart';
import 'package:player/services/on_demand_api.dart';
import 'package:player/services/wp_schedule_api.dart';
import 'package:provider/provider.dart';

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
    shows = Provider.of<OnDemandApiService>(context).getOnDemandPrograms();
    super.didChangeDependencies();
  }

  Future<List<OnDemandProgram>> shows;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<OnDemandProgram>>(
      future: shows.then((value) {
        value.sort((a, b) => a.name.compareTo(b.name));
        return value;
      }),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: Container(
                  height: 120,
                  child: Text(snapshot.data[index].slug ?? ''),
                ),
              ),
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
