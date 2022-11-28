import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:home_to_do/data_types/category.dart';
import 'package:home_to_do/pages/search_page.dart';
import 'package:home_to_do/pages/task_page.dart';
import 'package:home_to_do/pages/users_page.dart';
import 'package:home_to_do/pages/categories_page.dart';
import 'package:home_to_do/utilities/categories_utilities.dart';
import 'package:home_to_do/utilities/task_utilities.dart';
import 'custom_widgets/category_horizontal_list_view.dart';
import 'data_types/task.dart';
import 'data_types/user.dart';
import 'utilities/globals.dart' as globals;

Future<void> main() async {
  runApp(const MyApp());
}

Future<bool> initializeApplicationVariables() async {
  // Load categories and tasks from file
  await globals.categoriesStorage.loadCategoriesFromFile();
  await globals.tasksStorage.loadTasksIDFromFile();
  await globals.tasksStorage.loadTasksFromFile();

  // TODO: REMOVE IN PRODUCTION!
  //await globals.categoriesStorage.saveCategoriesToFile([Category(name:"All",emoji: "🏠")]);
  //await globals.tasksStorage.saveTasksToFile([]);
  for (var i = 0; i < globals.tasks.length; i++) {}
  return true;
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: initializeApplicationVariables(),
        builder: (context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData) {
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
          } else {
            return MaterialApp(
              title: "Home-ToDo",
              theme: ThemeData(
                  scaffoldBackgroundColor: const Color.fromRGBO(42, 42, 42, 100),
                  colorScheme: const ColorScheme.light(
                    primary: Colors.white,
                    onPrimary: Colors.black,
                    secondary: Colors.amber,
                  )),
              home: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const SizedBox(width: 60, height: 60, child: CircularProgressIndicator()),
                  DefaultTextStyle(
                      style: Theme
                          .of(context)
                          .textTheme
                          .headline1!,
                      child: const Text(
                        "Loading data...",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ))
                ],
              ),
            );
          }
        });
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

  @override
  Widget build(BuildContext context) {
    print("build main screen state");

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
          debugPrint("Add task button pressed");
          Navigator.push(context, MaterialPageRoute(builder: (context) => TaskScreen(mode: "Add"))).then((value) => setState(() {}));
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
                setState(() {
                  Navigator.pop(context);
                });
              },
            ),
            ListTile(
              title: const Text('Item 2'),
              onTap: () {
                setState(() {
                  Navigator.pop(context);
                });
              },
            ),
          ],
        ),
      ),
      body: Stack(children: <Widget>[
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              height: 45,
              child: CategoryHorizontalListView(categories: globals.categories),
            ),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: listOfTaskBuilder(context),
              ),
            ),
          ],
        ),
        UserSelectionDropUp(key: userSelectionDropUpKey),
      ]),
    );
  }
}

List<Widget> listOfTaskBuilder(BuildContext context) {
  List<Task> tasks = globals.tasks;

  print("called");
  print(tasks.length);

  List<Widget> taskTiles = [];

  for (var i = 0; i < tasks.length; i++) {
    Widget taskTile = TaskListTileBuilder(context, tasks[i]);
    taskTiles.add(taskTile);
  }

  return taskTiles;
}

Widget TaskListTileBuilder(context, Task task) {
  return Padding(
    padding: const EdgeInsets.only(left: 6, right: 6, top: 3, bottom: 3),
    child: Container(
      color: Colors.white,
      child: const ListTile(
        leading: Text("asd"),
        title: Text("asdone"),
        trailing: Text("miao"),
      )],

    ),
  );
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
    setState(() {}); // TODO ?? NO ??

    print("building add opt pop menu");
    return PopupMenuButton(
        onSelected: (int value) {
          setState(() {
            debugPrint("mhh");
            selectedValue = value;
            debugPrint(selectedValue.toString());
            if (value == 1) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SearchScreen())).then((_) => setState(() {}));
            }
            if (value == 2) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => CategoriesScreen())).then((_) => setState(() {}));
            }
            if (value == 3) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => UserScreen())).then((_) => setState(() {}));
            }
          });
        },
        itemBuilder: (context) =>
        [
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
        debugPrint("Show user selection");
        widget.showUserDropUpFunction!();
      }
      if (index == 3) {
        debugPrint("Show main menu");
        Scaffold.of(context).openDrawer();
      }
      if (index == 1) {
        debugPrint("Switch to list view");
      }
      if (index == 2) {
        debugPrint("Switch to calendar view");
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
      unselectedItemColor: Theme
          .of(context)
          .scaffoldBackgroundColor,
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
