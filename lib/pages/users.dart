import 'package:flutter/material.dart';

class UserScreen extends StatefulWidget {
  UserScreen({Key? key}) : super(key: key);

  @override
  State<UserScreen> createState() => UserScreenState();
}

class UserScreenState extends State<UserScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            print("Add user button pressed");
          },
          tooltip: "Create a new user",
          child: const Icon(Icons.add),
        ),
        body: Container( // PODIUM TEST
          height: 250,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [Expanded(child: Container()), Expanded(child: Container(child:Center(child: Text("2°",style: TextStyle(color: Colors.black, fontSize: 30),)),height: 70, color: Colors.white)),Expanded(child: Container(child:Center(child: Text("1°",style: TextStyle(color: Colors.black, fontSize: 30),)),height: 150, color: Colors.white)),Expanded(child: Container(child:Center(child: Text("3°",style: TextStyle(color: Colors.black, fontSize: 30),)),height: 110, color: Colors.white)), Expanded(child: Container())],
          ),
        ));
  }
}

class AdditionalOptionsPopUpMenu extends StatefulWidget {
  const AdditionalOptionsPopUpMenu({Key? key}) : super(key: key);

  @override
  State<AdditionalOptionsPopUpMenu> createState() => AdditionalOptionsPopUpMenuState();
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
