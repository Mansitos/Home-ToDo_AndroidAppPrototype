import 'package:flutter/material.dart';
import 'package:home_to_do/custom_widgets/user_form_dialog.dart';
import 'package:home_to_do/custom_widgets/user_tile.dart';
import 'package:home_to_do/data_types/rank_history_entry.dart';
import 'package:home_to_do/data_types/user.dart';
import 'package:home_to_do/pages/rank_history_page.dart';
import 'package:home_to_do/utilities/globals.dart' as globals;
import 'package:home_to_do/utilities/rank_history_utilities.dart';
import 'package:home_to_do/utilities/users_utilities.dart';

import '../custom_widgets/pop_up_message.dart';
import '../utilities/generic_utilities.dart';

class UserScreen extends StatefulWidget {
  UserScreen({Key? key}) : super(key: key);

  @override
  State<UserScreen> createState() => UserScreenState();
}

class UserScreenState extends State<UserScreen> {
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
          title: Text("Users"),
          actions: const <Widget>[
            AdditionalOptionsPopUpMenu(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: "AddUser",
          onPressed: () {
            // Navigator.pop close the pop-up while showing the dialog.
            // We have to wait till the animations finish, and then open the dialog.
            WidgetsBinding.instance?.addPostFrameCallback((_) {
              setState(() {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return UserDialogForm(
                        modifyMode: false,
                        userToModify: User(name: "null_placeholder", score: 0),
                        onChange: () {
                          setState(() {});
                        },
                      );
                    }).then((_) => setState(() {}));
              });
            });
          },
          tooltip: "Create a new user",
          child: const Icon(Icons.add),
        ),
        body: Column(
          children: [
            PodiumWidget(usersList: _getUsersOrderedList()),
            _getRankHistoryIntervalText(),
            Divider(
              height: 20,
              color: Colors.white,
            ),
            _usersPageMainWidgetBuilder(context, refresh),
          ],
        ));
  }

  Widget _getRankHistoryIntervalText() {
    DateTime start;
    if (globals.rankHistoryEntries.length > 0) {
      start = globals.rankHistoryEntries[globals.rankHistoryEntries.length - 1].endDate;
    } else {
      start = DateTime(0);
    }
    return Text(
      "From: " + dateToString(start),
      style: TextStyle(color: Colors.white, fontSize: 15),
    );
  }
}

Widget _usersListWidgetBuilder(context, void Function() callback) {
  return Expanded(
    child: ListView(
      shrinkWrap: true,
      //scrollDirection: Axis.vertical,
      children: usersOrderedTileBuilder(context, callback, _getUsersOrderedList()),
    ),
  );
}

List<User> _getUsersOrderedList() {
  int userScoreComparison(User a, User b) {
    int scoreA = a.score;
    int scoreB = b.score;
    if (scoreA < scoreB) {
      return -1;
    } else if (scoreA > scoreB) {
      return 1;
    } else {
      return 0;
    }
  }

  List<User> usersOrdered = globals.users.sublist(1);
  usersOrdered.sort(userScoreComparison);
  usersOrdered = usersOrdered.reversed.toList();
  return usersOrdered;
}

List<Widget> usersOrderedTileBuilder(BuildContext context, void Function() rebuildCallback, List<User> usersOrdered) {
  List<Widget> userTiles = [];

  for (var i = 0; i < usersOrdered.length; i++) {
    Widget userTile = UserTileWidget(
      user: usersOrdered[i],
      onChange: () {
        rebuildCallback();
      },
    );
    userTiles.add(userTile);
  }
  return userTiles;
}

class AdditionalOptionsPopUpMenu extends StatefulWidget {
  const AdditionalOptionsPopUpMenu({Key? key}) : super(key: key);

  @override
  State<AdditionalOptionsPopUpMenu> createState() => AdditionalOptionsPopUpMenuState();
}

class PodiumWidget extends StatefulWidget {
  PodiumWidget({Key? key, required this.usersList}) : super(key: key);

  final List<User> usersList;

  @override
  State<PodiumWidget> createState() => PodiumWidgetState();
}

Widget _usersPageMainWidgetBuilder(
  BuildContext context,
  void Function() callback,
) {
  if (globals.users.length > 1) {
    return _usersListWidgetBuilder(context, callback);
  } else {
    return _noUsersWidgetBuilder();
  }
}

Widget _noUsersWidgetBuilder() {
  return Center(
      child: Padding(
    padding: const EdgeInsets.all(50),
    child: SizedBox(
      height: 300,
      child: Column(
        children: const [
          Text("No Users Found!", style: TextStyle(fontSize: 24, color: Colors.white)),
          Padding(
            padding: EdgeInsets.all(12),
            child: Center(
              child: Text("👻",
                  style: TextStyle(
                    fontSize: 45, // !!! WARNING: if too big: BUG on RENDER
                  )),
            ),
          ),
          Text(
            "Try to create a new user by pressing the + button at the bottom right!",
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

class PodiumWidgetState extends State<PodiumWidget> {
  MediaQueryData? queryData;
  double screenWidth = 0;
  double screenHeight = 0;

  @override
  Widget build(BuildContext context) {
    queryData = MediaQuery.of(context);
    screenWidth = queryData!.size.width;
    screenHeight = queryData!.size.height;

    return Column(
      children: [
        Container(
          height: screenHeight * 0.035,
        ),
        Text(
          "🎖️ Users Ranking 🎖️",
          style: TextStyle(fontSize: 26, color: Colors.white),
        ),
        Container(
            // PODIUM TEST
            height: screenHeight * 0.29,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: Container()),
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                        padding: widget.usersList.length >= 2 ? EdgeInsets.all(2) : null,
                        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: widget.usersList.length >= 2
                            ? ClipOval(
                                child: SizedBox.fromSize(
                                  size: Size.fromRadius(20),
                                  child: widget.usersList[1].image == null
                                      ? Image.asset(
                                          "lib/assets/user_images/default_user_img.png",
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(
                                          widget.usersList[1].image!,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              )
                            : Container()),
                    Container(
                      height: 3,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Text(
                        widget.usersList.length >= 2 ? widget.usersList[1].name : "",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      height: screenHeight * 0.005,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadiusDirectional.only(
                            topStart: Radius.circular(10),
                            bottomStart: Radius.circular(5),
                          )),
                      child: Center(
                          child: Column(
                        children: [
                          Container(
                            height: screenHeight * 0.01,
                          ),
                          Text(
                            "2°",
                            style: TextStyle(color: Colors.black, fontSize: 30),
                          ),
                        ],
                      )),
                      height: screenHeight * 0.11,
                    ),
                  ],
                )),
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                        padding: widget.usersList.length >= 1 ? EdgeInsets.all(2) : null,
                        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: widget.usersList.length >= 1
                            ? ClipOval(
                                child: SizedBox.fromSize(
                                  size: Size.fromRadius(20),
                                  child: widget.usersList[0].image == null
                                      ? Image.asset(
                                          "lib/assets/user_images/default_user_img.png",
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(
                                          widget.usersList[0].image!,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              )
                            : Container()),
                    Container(
                      height: 3,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Text(
                        widget.usersList.length >= 1 ? widget.usersList[0].name : "",
                        style: TextStyle(color: Colors.white, fontSize: 15),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      height: screenHeight * 0.005,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadiusDirectional.only(
                            topStart: Radius.circular(10),
                            topEnd: Radius.circular(10),
                          )),
                      child: Center(
                          child: Column(
                        children: [
                          Container(
                            height: screenHeight * 0.01,
                          ),
                          Text(
                            "1°",
                            style: TextStyle(color: Colors.black, fontSize: 30),
                          ),
                        ],
                      )),
                      height: screenHeight * 0.17,
                    ),
                  ],
                )),
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                        padding: widget.usersList.length >= 3 ? EdgeInsets.all(2) : null,
                        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: widget.usersList.length >= 3
                            ? ClipOval(
                                child: SizedBox.fromSize(
                                  size: Size.fromRadius(20),
                                  child: widget.usersList[2].image == null
                                      ? Image.asset(
                                          "lib/assets/user_images/default_user_img.png",
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(
                                          widget.usersList[2].image!,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              )
                            : Container()),
                    Container(
                      height: 3,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Text(
                        widget.usersList.length >= 3 ? widget.usersList[2].name : "",
                        style: TextStyle(color: Colors.white, fontSize: 15),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      height: screenHeight * 0.005,
                    ),
                    Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadiusDirectional.only(topEnd: Radius.circular(10), bottomEnd: Radius.circular(5))),
                      child: Center(
                        child: Column(
                          children: [
                            Container(
                              height: screenHeight * 0.01,
                            ),
                            Text(
                              "3°",
                              style: TextStyle(color: Colors.black, fontSize: 30),
                            ),
                          ],
                        ),
                      ),
                      height: screenHeight * 0.08,
                    ),
                  ],
                )),
                Expanded(child: Container())
              ],
            )),
        Container(
          height: screenHeight * 0.0135,
        )
      ],
    );
  }
}

class AdditionalOptionsPopUpMenuState extends State<AdditionalOptionsPopUpMenu> {
  int selectedValue = 0;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
        onSelected: (int value) {
          setState(() {
            selectedValue = value;
            print(selectedValue);
            if (value == 1) {}
            if (value == 2) {}
            if (value == 3) {}
          });
        },
        itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text("Reset Ranking"),
                value: 1,
                onTap: () {
                  // Navigator.pop close the pop-up while showing the dialog.
                  // We have to wait till the animations finish, and then open the dialog.
                  WidgetsBinding.instance?.addPostFrameCallback((_) {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Column(
                              children: [
                                Icon(
                                  Icons.loop,
                                  color: Colors.red,
                                  size: 80,
                                ),
                                Text(
                                  "Are you sure you want to reset users ranking?",
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  "By doing so, scores will be set to zero and ongoing rankings will be saved on history!",
                                  style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w400),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                            actions: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    FloatingActionButton(
                                      heroTag: "UndoUsersRanking",
                                      backgroundColor: Colors.redAccent,
                                      onPressed: () {
                                        setState(() {
                                          debugPrint("Undo Users Ranking Reset!");
                                          Navigator.of(context).pop();
                                        });
                                      },
                                      tooltip: "Reset Users Ranking",
                                      child: const Icon(Icons.cancel),
                                    ),
                                    FloatingActionButton(
                                      heroTag: "ConfirmUsersRanking",
                                      onPressed: () async {
                                        debugPrint("Users Ranking Reset!");
                                        await _resetRanking();
                                        Navigator.of(context).pop();
                                        if (globals.users.length > 1) {
                                          showPopUpMessage(context, "🔁", "Users Ranking Reset Completed!\nScores saved on ranking history.", 2000);
                                        } else {
                                          showPopUpMessage(context, "👻", "Nothing to Reset!\nThere are no users...", 2000);
                                        }
                                      },
                                      tooltip: "Confirm",
                                      child: const Icon(Icons.check),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        });
                  });
                },
              ),
              PopupMenuItem(
                child: const Text("Ranking History"),
                value: 2,
                onTap: () {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => RankHistoryScreen()));
                  });
                },
              )
            ]);
  }

  Future<void> _resetRanking() async {
    DateTime? lastEntryEndDate;

    if (globals.rankHistoryEntries.length == 0) {
      lastEntryEndDate = DateTime(0);
    } else {
      lastEntryEndDate = globals.rankHistoryEntries[globals.rankHistoryEntries.length - 1].endDate;
    }

    List<User> usersOrdered = _getUsersOrderedList();

    String firstName = "None";
    String secondName = "None";
    String thirdName = "None";

    int firstScore = 0;
    int secondScore = 0;
    int thirdScore = 0;

    if (usersOrdered.isNotEmpty) {
      if (usersOrdered.length >= 1) {
        firstName = usersOrdered[0].name;
        firstScore = usersOrdered[0].score;
      }

      if (usersOrdered.length >= 2) {
        secondName = usersOrdered[1].name;
        secondScore = usersOrdered[1].score;
      }

      if (usersOrdered.length >= 3) {
        thirdName = usersOrdered[2].name;
        thirdScore = usersOrdered[2].score;
      }

      await createNewRankHistoryEntry(lastEntryEndDate, DateTime.now(), firstName, secondName, thirdName, firstScore, secondScore, thirdScore);

      for (int i = 0; i <= globals.users.length - 1; i++) {
        User userToModify = globals.users[i];
        if (userToModify.name != "All") {
          userToModify.removeScore(userToModify.score);
        }
      }

      debugPrint("> Rank reset completed!");
    } else {
      debugPrint("> No rank reset completed... no users!");
    }
  }
}
