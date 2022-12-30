import 'package:flutter/material.dart';
import 'package:home_to_do/custom_widgets/user_form_dialog.dart';
import 'package:home_to_do/custom_widgets/user_tile.dart';
import 'package:home_to_do/data_types/user.dart';
import 'package:home_to_do/utilities/globals.dart' as globals;

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
                          setState(() {
                            debugPrint("ASDONEEEEE");
                          });
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
            Divider(
              color: Colors.white,
            ),
            _usersPageMainWidgetBuilder(context, refresh),
          ],
        ));
  }
}

Widget _usersListWidgetBuilder(context, void Function() callback) {
  return ListView(
    shrinkWrap: true,
    scrollDirection: Axis.vertical,
    children: usersOrderedTileBuilder(context, callback, _getUsersOrderedList()),
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
          Text("No users found!", style: TextStyle(fontSize: 24, color: Colors.white)),
          Padding(
            padding: EdgeInsets.all(12),
            child: Center(
              child: Text("👻",
                  style: TextStyle(
                    fontSize: 70,
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
          height: screenHeight * 0.04,
        ),
        Text(
          "🏆 Users Ranking",
          style: TextStyle(fontSize: 25, color: Colors.white),
        ),
        Container(
            // PODIUM TEST
            height: screenHeight * 0.28,
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
                    Text(
                      widget.usersList.length >= 2 ? widget.usersList[1].name : "",
                      style: TextStyle(color: Colors.white, fontSize: 15),
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
                    Text(
                      widget.usersList.length >= 1 ? widget.usersList[0].name : "",
                      style: TextStyle(color: Colors.white, fontSize: 15),
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
                    Text(
                      widget.usersList.length >= 3 ? widget.usersList[2].name : "",
                      style: TextStyle(color: Colors.white, fontSize: 15),
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
          height: screenHeight * 0.0125,
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
                child: const Text("opt1"),
                value: 1,
                onTap: () {},
              ),
              PopupMenuItem(
                child: const Text("opt2"),
                value: 2,
                onTap: () {},
              ),
              PopupMenuItem(
                child: const Text("opt3"),
                value: 3,
                onTap: () {},
              ),
            ]);
  }
}
