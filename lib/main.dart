import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:home_to_do/pages/search_page.dart';
import 'package:home_to_do/pages/task_page.dart';
import 'package:home_to_do/pages/users_page.dart';
import 'package:home_to_do/pages/categories_page.dart';
import 'custom_widgets/category_horizontal_list_view.dart';
import 'custom_widgets/task_tile.dart';
import 'custom_widgets/user_selection_dropup.dart';
import 'data_types/task.dart';
import 'utilities/globals.dart' as globals;

Future<void> main() async {
  runApp(const MyApp());
}

Future<bool> initializeApplicationVariables() async {
  // Load categories and tasks from file
  await globals.categoriesStorage.loadCategoriesFromFile();
  await globals.tasksStorage.loadTasksIDFromFile();
  await globals.tasksStorage.loadTasksFromFile();

  // TODO: THINGS TO REMOVE IN PRODUCTION!
  await globals.categoriesStorage.saveCategoriesToFile([]);
  await globals.tasksStorage.saveTasksToFile([]);
  for (var i = 0; i < globals.tasks.length; i++) {
    // ...
  }
  return true;
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: initializeApplicationVariables(),
        builder: (context, AsyncSnapshot<bool> snapshot) {
          // If Application Initialized....
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
            // If Application did not finish initialization phase....
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
                      style: Theme.of(context).textTheme.headline1!,
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
  final userSelectionDropUpKey = GlobalKey<UserSelectionDropUpWidgetState>();

  // Show/Hide user pop-up widget
  void showUserDropUp() {
    userSelectionDropUpKey.currentState!.setState(() {
      userSelectionDropUpKey.currentState!.changeIsVisible();
    });
  }

  void rebuildMainScreen(){
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerEnableOpenDragGesture: false,
      appBar: AppBar(
        elevation: 1,
        automaticallyImplyLeading: false,
        title: const MainScreenTimeIntervalSelectionDropdown(),
        actions: <Widget>[
          MainScreenAdditionalOptionsDropdown(rebuildMainScreenCallback: rebuildMainScreen),
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
              title: const Text('Option 1'),
              onTap: () {
                setState(() {
                  Navigator.pop(context);
                });
              },
            ),
            ListTile(
              title: const Text('Option 2'),
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
              child: _tasksPageMainWidgetBuilder(context, rebuildMainScreen),
            ),
          ],
        ),
        UserSelectionDropUpWidget(key: userSelectionDropUpKey),
      ]),
    );
  }
}

List<Widget> listOfTaskBuilder(BuildContext context, void Function() rebuildMainScreenCallback) {
  List<Task> tasks = globals.tasks;
  List<Widget> taskTiles = [];



  for (var i = 0; i < tasks.length; i++) {
    Widget taskTile = TaskTileWidget(
      task: tasks[i],
      onChange: () {
        rebuildMainScreenCallback();
      },
    );
    taskTiles.add(taskTile);
  }
  return taskTiles;
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenAdditionalOptionsDropdown extends StatefulWidget {
  MainScreenAdditionalOptionsDropdown({Key? key, required this.rebuildMainScreenCallback}) : super(key: key);

  void Function() rebuildMainScreenCallback;

  @override
  State<MainScreenAdditionalOptionsDropdown> createState() => MainScreenAdditionalOptionsDropdownState();
}

class MainScreenTimeIntervalSelectionDropdown extends StatefulWidget {
  const MainScreenTimeIntervalSelectionDropdown({Key? key}) : super(key: key);

  @override
  State<MainScreenTimeIntervalSelectionDropdown> createState() => MainScreenTimeIntervalSelectionDropdownState();
}

class MainMenuBottomNavBar extends StatefulWidget {
  final GlobalKey? userDropUpWidgetKey;

  final Function? showUserDropUpFunction;

  const MainMenuBottomNavBar({Key? key, this.userDropUpWidgetKey, this.showUserDropUpFunction}) : super(key: key);

  @override
  State<MainMenuBottomNavBar> createState() => MainMenuBottomNavBarState();
}

class MainScreenAdditionalOptionsDropdownState extends State<MainScreenAdditionalOptionsDropdown> {
  int selectedValue = 0;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
        onSelected: (int value) {
          setState(() {
            debugPrint("mhh");
            selectedValue = value;
            debugPrint(selectedValue.toString());
            if (value == 1) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SearchScreen())).then((_) => setState(() {widget.rebuildMainScreenCallback();}));
            }
            if (value == 2) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => CategoriesScreen())).then((_) => setState(() {widget.rebuildMainScreenCallback();}));
            }
            if (value == 3) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => UserScreen())).then((_) => setState(() {widget.rebuildMainScreenCallback();}));
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

Widget _tasksPageMainWidgetBuilder(context, void Function() test) {
  // TODO: change with "filtered tasks to visualize, placeholder for now.."
  if (globals.tasks.isNotEmpty) {
    return ListView(
      shrinkWrap: true,
      children: listOfTaskBuilder(context, test),
    );
  } else {
    return _noTasksWidgetBuilder();
  }
}

Widget _noTasksWidgetBuilder() {
  print("asd");
  return Center(
      child: Padding(
    padding: const EdgeInsets.all(50),
    child: SizedBox(
      height: 300,
      child: Column(
        children: const [
          Text("No tasks found!", style: TextStyle(fontSize: 22, color: Colors.white)),
          Padding(
            padding: EdgeInsets.all(12),
            child: Text(" 🔍",
                style: TextStyle(
                  fontSize: 75,
                )),
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
      unselectedItemColor: Theme.of(context).scaffoldBackgroundColor,
      currentIndex: selectedIndex,
      onTap: _onItemTapped,
    );
  }
}

class MainScreenTimeIntervalSelectionDropdownState extends State<MainScreenTimeIntervalSelectionDropdown> {
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
            items: selectedMainScreenTimeIntervalSelectionDropdownItems));
  }
}

List<DropdownMenuItem<String>> get selectedMainScreenTimeIntervalSelectionDropdownItems {
  List<DropdownMenuItem<String>> items = const [
    DropdownMenuItem(child: Text("Today"), value: "Today"),
    DropdownMenuItem(child: Text("Tomorrow"), value: "Tomorrow"),
    DropdownMenuItem(child: Text("This Week"), value: "This Week"),
    DropdownMenuItem(child: Text("This Month"), value: "This Month"),
    DropdownMenuItem(child: Text("Custom Interval"), value: "Custom Interval"),
  ];
  return items;
}
