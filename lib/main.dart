import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:home_to_do/pages/search.dart';
import 'package:home_to_do/pages/task_create_modify.dart';
import 'package:home_to_do/pages/users.dart';
import 'package:home_to_do/pages/categories.dart';
import 'custom_widgets/category_horizontal_list_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Home-ToDo",
      theme: ThemeData(
          scaffoldBackgroundColor: const Color.fromRGBO(42, 42, 42, 100),
          colorScheme: const ColorScheme.light(
            primary: Colors.white,
            onPrimary: Colors.black,
            secondary: Colors.amber,
          )),
      home: const MainScreen(),
    );
  }
}

class MainScreenState extends State<MainScreen> {
  final userSelectionDropUpKey = GlobalKey<UserSelectionDropUpState>();

  // When called enable or disable (visible = !visible) the user selection widget
  void showUserDropUp() {
    userSelectionDropUpKey.currentState!.setState(() {
      userSelectionDropUpKey.currentState!.changeIsVisible();
    });
  }

  var _taskTapPosition;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Disable the swipe gesture to open the side-drawer
      drawerEnableOpenDragGesture: false,
      //backgroundColor: MyApp.mainBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const TimeIntervalDropdown(),
        actions: const <Widget>[
          AdditionalOptionsPopUpMenu(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "AddTask",
        onPressed: () {
          print("Add task button pressed");
          Navigator.push(context, MaterialPageRoute(builder: (context) => TaskScreen(mode: "Add")));
        },
        tooltip: "Schedule a new task",
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: MainMenuBottomNavBar(
        userDropUpWidgetKey: userSelectionDropUpKey,
        showUserDropUpFunction: showUserDropUp,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(),
              child: Text('Home To-Do'),
            ),
            ListTile(
              title: const Text('Item 1'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Item 2'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Stack(children: <Widget>[
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(
              height: 45,
              child: CategoryHorizontalListView(categories: ["🏠 All", "🌳 Garden", "🍴 Kitchen", "😽 Cat", "🚾 Bathroom", "🍔 Food"]),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemBuilder: (ctx, int) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 5, right: 5, top: 1, bottom: 0),
                    child: GestureDetector(
                      onTapDown: _storePosition,
                      child: Card(
                        child: TaskListTileBuilder(context,widget.key,_taskTapPosition),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        UserSelectionDropUp(key: userSelectionDropUpKey),
      ]),
    );
  }

  void _storePosition(TapDownDetails details) {
    _taskTapPosition = details.globalPosition;
    print("Task being onLongPressed");
  }

}

Widget TaskListTileBuilder(context,key,tapPosition) {


  return ListTile(
      onLongPress: () {
        final RenderBox renderBox = context.findRenderObject();
        showMenu(
          context: context,
          position: RelativeRect.fromRect(
              tapPosition & Size(0,0), // smaller rect, the touch area
              Offset.zero & overlay.size // Bigger rect, the entire screen
          ),
          items: <PopupMenuEntry>[
            PopupMenuItem(
              //value: this._index,
              child: Row(
                children: const [Text("Modify"),Text("Delete")],
              ),
            )
          ],
        );
      },
      title: Text('Task'),
      subtitle: const Text('This is a description of the task!'));
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => MainScreenState();
}

class UserSelectionDropUp extends StatefulWidget {
  const UserSelectionDropUp({Key? key}) : super(key: key);

  @override
  State<UserSelectionDropUp> createState() => UserSelectionDropUpState();
}

class AdditionalOptionsPopUpMenu extends StatefulWidget {
  const AdditionalOptionsPopUpMenu({Key? key}) : super(key: key);

  @override
  State<AdditionalOptionsPopUpMenu> createState() => AdditionalOptionsPopUpMenuState();
}

class TimeIntervalDropdown extends StatefulWidget {
  const TimeIntervalDropdown({Key? key}) : super(key: key);

  @override
  State<TimeIntervalDropdown> createState() => TimeIntervalDropdownState();
}

class MainMenuBottomNavBar extends StatefulWidget {
  final GlobalKey? userDropUpWidgetKey;

  final Function? showUserDropUpFunction;

  const MainMenuBottomNavBar({Key? key, this.userDropUpWidgetKey, this.showUserDropUpFunction}) : super(key: key);

  @override
  State<MainMenuBottomNavBar> createState() => MainMenuBottomNavBarState();
}

class UserSelectionDropUpState extends State<UserSelectionDropUp> {
  int selectedUserIndex = 0;
  bool isVisible = false;

  changeIsVisible() => {isVisible = !isVisible};

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isVisible,
      child: Align(
        child: Container(
          height: 250,
          width: 70,
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Container(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemBuilder: (ctx, int) {
                    return Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5, top: 1, bottom: 0),
                        child: ElevatedButton(
                          child: const Text("A"),
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(shape: const CircleBorder(), fixedSize: const Size(20, 20)),
                        ));
                  },
                ),
              ),
            ),
          ),
        ),
        alignment: const FractionalOffset(0.25 / 4, 1),
      ),
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
            if (value == 1) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SearchScreen()));
            }
            if (value == 2) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => CategoriesScreen()));
            }
            if (value == 3) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => UserScreen()));
            }
          });
        },
        itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text("Search"),
                value: 1,
                onTap: () {},
              ),
              PopupMenuItem(
                child: const Text("Manage Categories"),
                value: 2,
                onTap: () {},
              ),
              PopupMenuItem(
                child: const Text("Manage Users"),
                value: 3,
                onTap: () {},
              ),
            ]);
  }
}

class MainMenuBottomNavBarState extends State<MainMenuBottomNavBar> {
  int selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      if (index == 1 || index == 2) {
        selectedIndex = index;
      }
      if (index == 0) {
        print("Show user selection");
        widget.showUserDropUpFunction!();
      }
      if (index == 3) {
        print("Show main menu");
        Scaffold.of(context).openDrawer();
      }
      if (index == 1) {
        print("Switch to list view");
      }
      if (index == 2) {
        print("Switch to calendar view");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.people), label: "Users"),
        BottomNavigationBarItem(icon: Icon(Icons.view_list), label: "List View"),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Calendar View"),
        BottomNavigationBarItem(icon: Icon(Icons.menu), label: "Main Menu"),
      ],
      selectedItemColor: Colors.amber,
      unselectedItemColor: Theme.of(context).scaffoldBackgroundColor,
      currentIndex: selectedIndex,
      onTap: _onItemTapped,
    );
  }
}

class TimeIntervalDropdownState extends State<TimeIntervalDropdown> {
  String dropdownValue = 'Today';

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
        child: DropdownButton<String>(
            value: dropdownValue,
            icon: const Icon(Icons.arrow_drop_down),
            onChanged: (String? newValue) {
              setState(() {
                dropdownValue = newValue!;
              });
            },
            items: selectedTimeIntervalDropdownItems));
  }
}

List<DropdownMenuItem<String>> get selectedTimeIntervalDropdownItems {
  List<DropdownMenuItem<String>> items = const [
    DropdownMenuItem(child: Text("Today"), value: "Today"),
    DropdownMenuItem(child: Text("Tomorrow"), value: "Tomorrow"),
    DropdownMenuItem(child: Text("This Week"), value: "This Week"),
    DropdownMenuItem(child: Text("This Month"), value: "This Month"),
    DropdownMenuItem(child: Text("Custom Interval"), value: "Custom Interval"),
  ];
  return items;
}
