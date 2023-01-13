import 'package:flutter/material.dart';
import 'package:home_to_do/data_types/rank_history_entry.dart';
import 'package:home_to_do/utilities/globals.dart' as globals;

import '../utilities/generic_utilities.dart';

class RankHistoryScreen extends StatefulWidget {
  RankHistoryScreen({Key? key}) : super(key: key);

  @override
  State<RankHistoryScreen> createState() => RankHistoryScreenState();
}

class RankHistoryScreenState extends State<RankHistoryScreen> {
  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      drawerEnableOpenDragGesture: false,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text("Users Ranking History"),
        actions: const <Widget>[],
      ),
      body: globals.rankHistoryEntries.length > 1
          ? ListView(
              shrinkWrap: true,
              children: rankHistoryTilesBuilder(context),
            )
          : _noRankingHistoryWidget(),
    );
  }

  List<Widget> rankHistoryTilesBuilder(BuildContext context) {
    List<Widget> rankHistoryTiles = [];

    TextStyle titleStyle = TextStyle(fontSize: 16);
    TextStyle secondStyle = TextStyle(fontSize: 13);

    // i = 1 because skip the first one (the default for starting point one)
    for (var i = 1; i < globals.rankHistoryEntries.length; i++) {
      RankHistoryEntry entry = globals.rankHistoryEntries[i];

      Widget rankHistoryTile = Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            color: Colors.white,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(3),
                child: Text(
                  "From: " + dateToString(entry.startDate) + " to " + dateToString(entry.endDate),
                  style: titleStyle,
                ),
              ),
              Divider(
                height: 0.5,
                color: Colors.black54,
                thickness: 1,
              ),
              Padding(
                padding: const EdgeInsets.all(3),
                child: Text(
                  "1°: " + entry.firstUser + " with " + entry.firstScore.toString() + "⭐",
                  style: secondStyle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(3),
                child: Text(
                  "2°: " + entry.secondUser + " with " + entry.secondScore.toString() + "⭐",
                  style: secondStyle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(3),
                child: Text(
                  "3°: " + entry.thirdUser + " with " + entry.thirdScore.toString() + "⭐",
                  style: secondStyle,
                ),
              ),
            ],
          ),
        ),
      );
      rankHistoryTiles.add(rankHistoryTile);
    }

    return rankHistoryTiles;
  }

  Widget _noTasksWidgetBuilder() {
    return Center(
        child: Padding(
      padding: const EdgeInsets.all(50),
      child: SizedBox(
        child: Column(
          children: const [
            Text("No tasks found!", style: TextStyle(fontSize: 24, color: Colors.white)),
            Padding(
              padding: EdgeInsets.all(12),
              child: Center(
                child: Text("🔍",
                    style: TextStyle(
                      fontSize: 70,
                    )),
              ),
            ),
            Text(
              "There are no tasks matching the currently selected filters! You can rest 😝",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ));
  }

  Widget _noRankingHistoryWidget() {
    return Center(
        child: Padding(
      padding: const EdgeInsets.all(50),
      child: SizedBox(
        child: Column(
          children: const [
            Text(
              "Users Ranking History Empty!",
              style: TextStyle(fontSize: 24, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Center(
                child: Text("🕑",
                    style: TextStyle(
                      fontSize: 45, // !!! WARNING: if too big: BUG on RENDE
                    )),
              ),
            ),
            Text(
              "A new history entry will be created and available here when you will reset the users ranking!",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ));
  }
}
