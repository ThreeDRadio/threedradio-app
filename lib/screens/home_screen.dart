import 'package:flutter/material.dart';
import 'package:player/screens/live_broadcast_tab.dart';
import 'package:player/services/wp_schedule_api.dart';
import 'package:player/widgets/show_detail_header.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  @override
  TabController tabController;
  Future<Show> currentShow;
  initState() {
    tabController = TabController(
      length: 2,
      vsync: this,
    );
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Three D Radio'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.radio),
            title: Text('Live'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.offline_bolt),
            title: Text('On Demand'),
          ),
        ],
      ),
      body: PageView(
        children: [
          LiveBroadcastTab(),
        ],
      ),
    );
  }
}
