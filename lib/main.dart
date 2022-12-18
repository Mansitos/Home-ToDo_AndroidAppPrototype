import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:home_to_do/data_types/global_settings.dart';
import 'package:home_to_do/pages/search_page.dart';
import 'package:home_to_do/pages/task_page.dart';
import 'package:home_to_do/pages/users_page.dart';
import 'package:home_to_do/pages/categories_page.dart';
import 'package:path_provider/path_provider.dart';
import 'custom_widgets/category_horizontal_list_view.dart';
import 'custom_widgets/pop_up_message.dart';
import 'custom_widgets/task_tile.dart';
import 'custom_widgets/user_selection_dropup.dart';
import 'data_types/category.dart';
import 'data_types/task.dart';
import 'data_types/task_filter.dart';
import 'data_types/user.dart';
import 'utilities/globals.dart' as globals;

Future<void> main() async {
  runApp(const MyApp());
}

// Load internal variables from files: tasks, categories, etc.
Future<bool> initializeApplicationVariables() async {
  // Load categories and tasks from file
  await globals.categoriesStorage.loadCategoriesFromFile();
  await globals.tasksStorage.loadTasksFromFile();
  await globals.usersStorage.loadUsersFromFile();
  // Load global application variables
  await globals.globalSettingsStorage.loadGlobalSettingsFromFile();

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

  void rebuildMainScreen(bool restoreSelectedUser) {
    setState(() {
      if (restoreSelectedUser == true) {
        selectedUser = globals.users[0];
      }
    });
  }

  void completeTaskCallback(Task task) {
    if (task.getCompleted() == false) {
      task.completeTask(selectedUser!);
    } else {
      task.undoComplete();
    }
    rebuildMainScreen(false);
  }

  // By default, the default one (which is always in first pos)
  Category selectedCategory = globals.categories[0];

  // By default is "Today"
  DateTime? selectedStartingDate = DateTime.now();
  DateTime? selectedEndDate;

  // By default, the default one (which is always in first pos)
  User? selectedUser = globals.users[0];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerEnableOpenDragGesture: false,
      appBar: AppBar(
        elevation: 1,
        automaticallyImplyLeading: false,
        title: MainScreenTimeIntervalSelectionDropdown(
          onChange: (List<DateTime?> val) {
            selectedStartingDate = val[0];
            selectedEndDate = val[1];
            debugPrint("> Changed time filter:" + selectedStartingDate.toString() + " to " + selectedEndDate.toString());
            rebuildMainScreen(false);
          },
        ),
        actions: <Widget>[
          MainScreenAdditionalOptionsDropdown(rebuildMainScreenCallback: rebuildMainScreen),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "AddTask",
        onPressed: () {
          debugPrint("Add task button pressed");
          Navigator.push(context, MaterialPageRoute(builder: (context) => TaskScreen(mode: "Add"))).then((_) => setState(() {}));
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
            DrawerHeader(
              child: Column(
                children: [
                  Text(
                    'Home To-Do',
                    style: TextStyle(fontSize: 35),
                  ),
                  Container(height: 3,),
                  Expanded(
                    child: Container(child: Image.asset("lib/assets/logo.png")),
                  ),
                Container(height: 3,)],
              ),
            ),
            ListTile(
              title: Row(
                children: [
                  Icon(Icons.info_rounded, color: Colors.black,),
                  const Text(' About the app'),
                ],
              ),
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
                              const Text("About the App"),
                            ],
                          ),
                          content: const Text('This app was developed by Andrea Mansi for the university exam "Sviluppo di Applicazioni Mobili/Mobile Apps Development".\n\n🏛️ University of Udine 🇮🇹 Italy\nMaster\'s degree in Computer Science\nCurricula: Big-Data Analytics.\n\nThis is my first mobile application project and my first code in Dart+Flutter.\n\nPlease expect to find lots of bugs! 😝', textAlign: TextAlign.center),
                          actions: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  FloatingActionButton(
                                    heroTag: "Back",
                                    onPressed: () {
                                      setState(() {
                                        Navigator.of(context).pop();
                                      });
                                    },
                                    tooltip: "Back",
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
            Divider(height: 10),
            ListTile(
              title: Row(
                children: [
                  Icon(Icons.local_fire_department,color: Colors.red,),
                  const Text(' Wipe all data'),
                ],
              ),
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
                              Text(
                                "☠",
                                style: TextStyle(fontSize: 60),
                              ),
                              Text(
                                "Are you sure you want to wipe all data?",
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                "You can't undo this operation!",
                                style: TextStyle(color: Colors.red),
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
                                    heroTag: "UndoDataWipe",
                                    onPressed: () {
                                      setState(() {
                                        debugPrint("Wipe data cancelled!");
                                        Navigator.of(context).pop();
                                      });
                                    },
                                    tooltip: "Wipe All Data",
                                    child: const Icon(Icons.cancel),
                                  ),
                                  FloatingActionButton(
                                    heroTag: "ConfirmDataWipe",
                                    backgroundColor: Colors.redAccent,
                                    onPressed: () async {
                                      debugPrint("Data Wipe confirmed!");
                                      await _wipeAllData();
                                      Navigator.of(context).pop();
                                      showPopUpMessage(context, "🚀", "Data successfully sent into a black hole!\nIt's gone forever...", 2300);
                                      rebuildMainScreen(false);
                                    },
                                    tooltip: "Confirm",
                                    child: const Icon(Icons.delete),
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
            Divider(height: 10),
            ListTile(
              title: Row(
                children: [
                  Icon(Icons.star,color: Colors.amber,),
                  const Text(' Rate on the app store'),
                ],
              ),
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
                              const Text("Placeholder..."),
                            ],
                          ),
                          content: const Text('This button should bring you to play store so you can rate the app', textAlign: TextAlign.center),
                          actions: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  FloatingActionButton(
                                    heroTag: "Back",
                                    onPressed: () {
                                      setState(() {
                                        Navigator.of(context).pop();
                                      });
                                    },
                                    tooltip: "Back",
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
            Divider(height: 10),
            ListTile(
              title: Row(
                children: [
                  Icon(Icons.app_settings_alt, color: Colors.black,),
                  const Text(' Application settings'),
                ],
              ), // TODO: go to android settings page
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
                              const Text("Placeholder..."),
                            ],
                          ),
                          content: const Text('This button should bring you to the android app-settings for this app...', textAlign: TextAlign.center),
                          actions: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  FloatingActionButton(
                                    heroTag: "Back",
                                    onPressed: () {
                                      setState(() {
                                        Navigator.of(context).pop();
                                      });
                                    },
                                    tooltip: "Back",
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
            Divider(height: 10),
            ListTile(
              title: Row(
                children: [
                  globals.popUpMessagesEnabled ? Icon(Icons.check_circle, color: Colors.green,) : Icon(Icons.cancel, color: Colors.red,),
                  Text(globals.popUpMessagesEnabled ? ' Pop-Up messages' : ' Pop-Up messages'),
                ],
              ),
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
                              const Text("Pop-Up Messages"),
                            ],
                          ),
                          content: const Text('This option enables/disables pop-up messages, like for example:\n\"✅ New task created\".', textAlign: TextAlign.center),
                          actions: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        globals.popUpMessagesEnabled = false;
                                        debugPrint("Pop-Up messages disabled");
                                        globals.globalSettingsStorage.saveGlobalSettingsToFile(GlobalSettings(lastUniqueGeneratedID: globals.lastUniqueGeneratedID, popUpMessagesEnabled: globals.popUpMessagesEnabled, compactTaskListViewEnabled: globals.compactTaskListViewEnabled));
                                        Navigator.of(context).pop();
                                      });
                                    },
                                    child: Text(
                                      globals.popUpMessagesEnabled ? "Disable" : "Keep disabled",
                                      style: TextStyle(fontSize: 19, color: Colors.black),
                                    ),
                                    style: TextButton.styleFrom(backgroundColor: Colors.redAccent),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        globals.popUpMessagesEnabled = true;
                                        debugPrint("Pop-Up messages enabled");
                                        globals.globalSettingsStorage.saveGlobalSettingsToFile(GlobalSettings(lastUniqueGeneratedID: globals.lastUniqueGeneratedID, popUpMessagesEnabled: globals.popUpMessagesEnabled, compactTaskListViewEnabled: globals.compactTaskListViewEnabled));
                                        Navigator.of(context).pop();
                                      });
                                    },
                                    child: Text(
                                      globals.popUpMessagesEnabled ? "Keep enabled" : "Enable",
                                      style: TextStyle(fontSize: 19, color: Colors.black),
                                    ),
                                    style: TextButton.styleFrom(backgroundColor: Colors.amber),
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
            Divider(height: 10),
            ListTile(
              title: Row(
                children: [
                  globals.compactTaskListViewEnabled ? Icon(Icons.check_circle, color: Colors.green,) : Icon(Icons.cancel, color: Colors.red,),
                  Text(globals.compactTaskListViewEnabled ? ' Compact tasks-list view' : ' Compact tasks-list view'),
                ],
              ),
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
                              const Text("Compact Tasks List View"),
                            ],
                          ),
                          content: const Text('This option enables/disables compact view of the list of tasks.', textAlign: TextAlign.center),
                          actions: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        globals.compactTaskListViewEnabled = false;
                                        debugPrint("Compact Tasks List View Disabled");
                                        globals.globalSettingsStorage.saveGlobalSettingsToFile(GlobalSettings(lastUniqueGeneratedID: globals.lastUniqueGeneratedID, popUpMessagesEnabled: globals.popUpMessagesEnabled, compactTaskListViewEnabled: globals.compactTaskListViewEnabled));
                                        Navigator.of(context).pop();
                                      });
                                    },
                                    child: Text(
                                      globals.compactTaskListViewEnabled ? "Disable" : "Keep disabled",
                                      style: TextStyle(fontSize: 19, color: Colors.black),
                                    ),
                                    style: TextButton.styleFrom(backgroundColor: Colors.redAccent),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        globals.compactTaskListViewEnabled = true;
                                        debugPrint("Compact Tasks List View enabled");
                                        globals.globalSettingsStorage.saveGlobalSettingsToFile(GlobalSettings(lastUniqueGeneratedID: globals.lastUniqueGeneratedID, popUpMessagesEnabled: globals.popUpMessagesEnabled, compactTaskListViewEnabled: globals.compactTaskListViewEnabled));
                                        Navigator.of(context).pop();
                                      });
                                    },
                                    child: Text(
                                      globals.compactTaskListViewEnabled ? "Keep enabled" : "Enable",
                                      style: TextStyle(fontSize: 19, color: Colors.black),
                                    ),
                                    style: TextButton.styleFrom(backgroundColor: Colors.amber),
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
            Divider(height: 10),
          ],
        ),
      ),
      body: Stack(children: <Widget>[
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              height: 45,
              child: CategoryHorizontalListView(
                categories: globals.categories,
                onChange: (Category val) {
                  selectedCategory = val;
                  rebuildMainScreen(false);
                },
              ),
            ),
            _additionalUserWidgetText(),
            Expanded(
              child: _tasksPageMainWidgetBuilder(context, rebuildMainScreen, completeTaskCallback, TaskFilter(startingDate: selectedStartingDate!, endDate: selectedEndDate, category: selectedCategory, user: selectedUser)),
            ),
          ],
        ),
        UserSelectionDropUpWidget(
          key: userSelectionDropUpKey,
          onUserSelected: (User user) {
            debugPrint(" > User filter changed to: " + user.name);
            selectedUser = user;
            rebuildMainScreen(false);
          },
        ),
      ]),
    );
  }

  Future<void> _wipeAllData() async {
    // Wipe data...
    await globals.categoriesStorage.saveCategoriesToFile([]);
    await globals.tasksStorage.saveTasksToFile([]);
    await globals.usersStorage.saveUsersToFile([]);
    GlobalSettings wipedSettings = GlobalSettings(lastUniqueGeneratedID: 0, popUpMessagesEnabled: true, compactTaskListViewEnabled: false);
    await globals.globalSettingsStorage.saveGlobalSettingsToFile(wipedSettings);

    // Deleting all users pictures
    final directory = await getApplicationDocumentsDirectory();
    if (await Directory(directory.path + "/user_images/").existsSync()) {
      await new Directory(directory.path + "/user_images/").delete(recursive: true);
    }
    await new Directory(directory.path + "/user_images/").create(recursive: true);

    // Load wiped (re-generated-data) again...
    await initializeApplicationVariables();
  }

  Widget _additionalUserWidgetText() {
    if (selectedUser!.name != globals.users[0].name) {
      return Padding(
        padding: const EdgeInsets.all(6.0),
        child: Container(
            child: Text(
          "📝 Available tasks for " + selectedUser!.name + ":",
          style: TextStyle(color: Colors.white, fontSize: 14),
        )),
      );
    } else {
      return Container();
    }
  }
}

List<Widget> listOfTaskBuilder(BuildContext context, void Function(bool restoreSelectedUser) rebuildMainScreenCallback, void Function(Task) taskCompletedCallback, List<Task> filteredTasks) {
  List<Widget> taskTiles = [];

  for (var i = 0; i < filteredTasks.length; i++) {
    Widget taskTile = TaskTileWidget(
      task: filteredTasks[i],
      onChange: () {
        rebuildMainScreenCallback(false);
      },
      onTaskComplete: (Task val) {
        taskCompletedCallback(val);
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
  MainScreenAdditionalOptionsDropdown({Key? key, required this.rebuildMainScreenCallback(bool restoreSelectedUser)}) : super(key: key);

  void Function(bool restoreSelectedUser) rebuildMainScreenCallback;

  @override
  State<MainScreenAdditionalOptionsDropdown> createState() => MainScreenAdditionalOptionsDropdownState();
}

class MainScreenTimeIntervalSelectionDropdown extends StatefulWidget {
  const MainScreenTimeIntervalSelectionDropdown({Key? key, required this.onChange}) : super(key: key);

  final DateTimeRangeCallback onChange;

  @override
  State<MainScreenTimeIntervalSelectionDropdown> createState() => MainScreenTimeIntervalSelectionDropdownState();
}

typedef void DateTimeRangeCallback(List<DateTime?> val);

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
            selectedValue = value;
            debugPrint(selectedValue.toString());
            if (value == 1) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SearchScreen())).then((_) => setState(() {
                    widget.rebuildMainScreenCallback(false); // TODO: check if needed
                  }));
            }
            if (value == 2) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => CategoriesScreen())).then((_) => setState(() {
                    widget.rebuildMainScreenCallback(false); // TODO: check if needed
                  }));
            }
            if (value == 3) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => UserScreen())).then((_) => setState(() {
                    widget.rebuildMainScreenCallback(true);
                  }));
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

List<Task> getSelectedTasksList(TaskFilter selectionFilter) {
  List<Task> allTasks = globals.tasks;
  return selectionFilter.applyTo(allTasks,true);
}

Widget _tasksPageMainWidgetBuilder(context, void Function(bool restoreSelectedUser) callback, void Function(Task) completeTaskCallback, TaskFilter selectionFilter) {
  List<Task> filteredTasks = getSelectedTasksList(selectionFilter);

  if (filteredTasks.isNotEmpty) {
    return ListView(
      shrinkWrap: true,
      children: listOfTaskBuilder(context, callback, completeTaskCallback, filteredTasks),
    );
  } else {
    return _noTasksWidgetBuilder();
  }
}

Widget _noTasksWidgetBuilder() {
  return Center(
      child: Padding(
    padding: const EdgeInsets.all(50),
    child: SizedBox(
      height: 300,
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
  List<DateTime?> customInterval = [];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
              value: dropdownValue,
              icon: const Icon(Icons.arrow_drop_down),
              onChanged: (String? newValue) {
                setState(() async {
                  var oldValue = dropdownValue;
                  dropdownValue = newValue!;
                  List<DateTime?> dates = await _getTimeRange(dropdownValue);
                  if (dates == []) {
                    dropdownValue = oldValue;
                    // do not update!
                  } else {
                    widget.onChange(dates);
                  }

                  if(dropdownValue == "Custom Interval"){
                    customInterval = dates;
                  }else{
                    customInterval = [];
                  }

                });
              },
              items: selectedMainScreenTimeIntervalSelectionDropdownItems)),
    );
  }

  Future<List<DateTime?>> _getTimeRange(String value) async {
    DateTime today = DateTime.now();
    switch (value) {
      case "Today":
        return [today, null];
      case "Tomorrow":
        return [DateTime(today.year, today.month, today.day + 1), null];
      case "This Week":
        return [today, DateTime(today.year, today.month, today.day + 7)];
      case "This Month":
        return [today, DateTime(today.year, today.month + 1, today.day)];
      case "Custom Interval":
        return await _dateTimeRangeSelection();
      default:
        return [];
    }
  }

  Future<List<DateTime?>> _dateTimeRangeSelection() async {
    DateTime today = DateTime.now();
    DateTimeRange dateRange;
    if(customInterval.isEmpty) {
      dateRange = DateTimeRange(start: today, end: DateTime(today.year, today.month, today.day + 4));
    }else{
      dateRange = DateTimeRange(start: customInterval[0]!, end: customInterval[1]!);
    }

    DateTimeRange? newDateRange = await showDateRangePicker(
        context: context,
        initialDateRange: dateRange,
        firstDate: DateTime(2000),
        lastDate: DateTime(2500),
        helpText: "Time Range Selection",
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.dark(
                primary: Colors.amber,
                onPrimary: Colors.black,
                onSurface: Colors.black,
                surface: Colors.white,
                background: Colors.white,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  primary: Colors.black, // button text color
                ),
              ),
            ),
            child: child!,
          );
        });

    if (newDateRange == null) {
      return [];
    } else {
      return [newDateRange.start, newDateRange.end];
    }
  }

  List<DropdownMenuItem<String>> get selectedMainScreenTimeIntervalSelectionDropdownItems {
    List<DropdownMenuItem<String>> items = [
      DropdownMenuItem(child: Text("Today"), value: "Today"),
      DropdownMenuItem(child: Text("Tomorrow"), value: "Tomorrow"),
      DropdownMenuItem(child: Text("This Week"), value: "This Week"),
      DropdownMenuItem(child: Text("This Month"), value: "This Month"),
      DropdownMenuItem(child: _getCustomIntervalDropDownText(dropdownValue), value: "Custom Interval"),
    ];
    return items;
  }

  Widget _getCustomIntervalDropDownText(String dropdownValue) {
    if (dropdownValue != "Custom Interval") {
      return Text("Custom Interval");
    } else {
      return Text(monthToText(customInterval[0]!.month) + " " + customInterval[0]!.day.toString() + " - " + monthToText(customInterval[1]!.month) + " " + customInterval[1]!.day.toString());
    }
  }
}

String monthToText(int month) {
  switch (month) {
    case 1:
      return ("Jan");
    case 2:
      return ("Feb");
    case 3:
      return ("Mar");
    case 4:
      return ("Apr");
    case 5:
      return ("May");
    case 6:
      return ("Jun");
    case 7:
      return ("Jul");
    case 8:
      return ("Aug");
    case 9:
      return ("Sep");
    case 10:
      return ("Oct");
    case 11:
      return ("Nov");
    case 12:
      return ("Dec");
    default:
      return ("ERROR");
  }
}
