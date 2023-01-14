import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:home_to_do/data_types/global_settings.dart';
import 'package:home_to_do/pages/task_page.dart';
import 'package:home_to_do/pages/users_page.dart';
import 'package:home_to_do/pages/categories_page.dart';
import 'package:home_to_do/utilities/generic_utilities.dart';
import 'package:home_to_do/utilities/notification_api.dart';
import 'package:home_to_do/utilities/task_utilities.dart';
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
  // Load global application variables
  await globals.globalSettingsStorage.loadGlobalSettingsFromFile();

  // Load categories, tasks, users and rank_history from file
  await globals.categoriesStorage.loadCategoriesFromFile();
  await globals.tasksStorage.loadTasksFromFile();
  await globals.usersStorage.loadUsersFromFile();
  await globals.rankHistoryStorage.loadRankHistoryFromFile();

  // Notifications init
  await LocalNoticeService().setup();

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
                  onSurface: Colors.white,
                ),
                textSelectionTheme: const TextSelectionThemeData(
                  selectionHandleColor: Colors.amber,
                ),
              ),
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

  void rebuildMainScreen(bool restoreSelectedUser, bool restoreSelectedCategory) {
    setState(() {
      if (restoreSelectedUser == true) {
        selectedUser = globals.users[0];
      }
      if (restoreSelectedCategory == true) {
        selectedCategory = globals.categories[0];
      }
    });
  }

  Future<void> completeTaskCallback(Task task) async {
    if (task.getCompleted() == false) {
      await task.completeTask(selectedUser!);
    } else {
      await task.undoComplete();
    }
    rebuildMainScreen(false, false);
  }

  // By default, the default one (which is always in first pos)
  Category selectedCategory = globals.categories[0];

  // By default is "Today"
  DateTime? selectedStartingDate = DateTime.now();
  DateTime? selectedEndDate;

  // By default, the default one (which is always in first pos)
  User? selectedUser = globals.users[0];

  // By default, list view
  String viewMode = "list";

  // Selected Time option
  String selectedTimeOption = "Today";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawerEnableOpenDragGesture: false,
        appBar: AppBar(
          elevation: 1,
          automaticallyImplyLeading: false,
          title: viewMode == "list"
              ? MainScreenTimeIntervalSelectionDropdown(
                  startingSelectedValue: selectedTimeOption,
                  viewMode: viewMode,
                  onChange: (List<DateTime?> val) {
                    if (val.isNotEmpty) {
                      selectedStartingDate = val[0];
                      if (val.length > 1) {
                        selectedEndDate = val[1];
                      } else {
                        selectedEndDate = val[0];
                      }
                    }
                    debugPrint("> Changed time filter:" + selectedStartingDate.toString() + " to " + selectedEndDate.toString());
                    rebuildMainScreen(false, false);
                  },
                  onSelection: (String val) {
                    setState(() {
                      selectedTimeOption = val;
                    });
                  },
                  startingCustomInterval: [selectedStartingDate, selectedEndDate],
                )
              : _getCalendarViewActiveText([selectedStartingDate, selectedEndDate]),
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
          changedViewModeCallback: (String val) {
            viewMode = val;
            rebuildMainScreen(false, false);

            globals.activeViewMode = val;
          },
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                child: Column(
                  children: [
                    const Text(
                      'Home To-Do',
                      style: TextStyle(fontSize: 35),
                    ),
                    Container(
                      height: 3,
                    ),
                    Expanded(
                      child: Container(child: Image.asset("lib/assets/logo.png")),
                    ),
                    Container(
                      height: 3,
                    )
                  ],
                ),
              ),
              ListTile(
                title: Row(
                  children: [
                    const Icon(
                      Icons.info_rounded,
                      color: Colors.black,
                    ),
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
              const Divider(
                height: 4,
              ),
              ListTile(
                title: Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: Colors.red,
                    ),
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
                                const Icon(
                                  Icons.warning,
                                  color: Colors.red,
                                  size: 80,
                                ),
                                const Text(
                                  "Are you sure you want to wipe all data?",
                                  style: TextStyle(
                                    color: Colors.red,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const Text(
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
                                        rebuildMainScreen(true, true);
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
              const Divider(
                height: 4,
              ),
              ListTile(
                title: Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
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
              const Divider(
                height: 4,
              ),
              ListTile(
                title: Row(
                  children: [
                    const Icon(
                      Icons.app_settings_alt,
                      color: Colors.black,
                    ),
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
              const Divider(
                height: 4,
              ),
              ListTile(
                title: Row(
                  children: [
                    globals.popUpMessagesEnabled
                        ? const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          )
                        : const Icon(
                            Icons.cancel,
                            color: Colors.red,
                          ),
                    Text(globals.popUpMessagesEnabled ? ' Pop-Up messages: Yes' : ' Pop-Up messages: No'),
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
                                          globals.globalSettingsStorage.saveGlobalSettingsToFile(GlobalSettings(lastUniqueGeneratedID: globals.lastUniqueGeneratedID, popUpMessagesEnabled: globals.popUpMessagesEnabled, compactTaskListViewEnabled: globals.compactTaskListViewEnabled, alwaysShowExpiredTasks: globals.alwaysShowExpiredTasks, autoMonthOldDelete: globals.autoMonthOldDelete));
                                          Navigator.of(context).pop();
                                        });
                                      },
                                      child: Text(
                                        globals.popUpMessagesEnabled ? "Disable" : "Keep disabled",
                                        style: const TextStyle(fontSize: 19, color: Colors.black),
                                      ),
                                      style: TextButton.styleFrom(backgroundColor: Colors.redAccent),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          globals.popUpMessagesEnabled = true;
                                          debugPrint("Pop-Up messages enabled");
                                          globals.globalSettingsStorage.saveGlobalSettingsToFile(GlobalSettings(lastUniqueGeneratedID: globals.lastUniqueGeneratedID, popUpMessagesEnabled: globals.popUpMessagesEnabled, compactTaskListViewEnabled: globals.compactTaskListViewEnabled, alwaysShowExpiredTasks: globals.alwaysShowExpiredTasks, autoMonthOldDelete: globals.autoMonthOldDelete));
                                          Navigator.of(context).pop();
                                        });
                                      },
                                      child: Text(
                                        globals.popUpMessagesEnabled ? "Keep enabled" : "Enable",
                                        style: const TextStyle(fontSize: 19, color: Colors.black),
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
              const Divider(
                height: 4,
              ),
              ListTile(
                title: Row(
                  children: [
                    globals.compactTaskListViewEnabled
                        ? const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          )
                        : const Icon(
                            Icons.cancel,
                            color: Colors.red,
                          ),
                    Text(globals.compactTaskListViewEnabled ? ' Compact tasks-list view: Yes' : ' Compact tasks-list view: No'),
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
                                          globals.globalSettingsStorage.saveGlobalSettingsToFile(GlobalSettings(lastUniqueGeneratedID: globals.lastUniqueGeneratedID, popUpMessagesEnabled: globals.popUpMessagesEnabled, compactTaskListViewEnabled: globals.compactTaskListViewEnabled, alwaysShowExpiredTasks: globals.alwaysShowExpiredTasks, autoMonthOldDelete: globals.autoMonthOldDelete));
                                          Navigator.of(context).pop();
                                        });
                                      },
                                      child: Text(
                                        globals.compactTaskListViewEnabled ? "Disable" : "Keep disabled",
                                        style: const TextStyle(fontSize: 19, color: Colors.black),
                                      ),
                                      style: TextButton.styleFrom(backgroundColor: Colors.redAccent),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          globals.compactTaskListViewEnabled = true;
                                          debugPrint("Compact Tasks List View enabled");
                                          globals.globalSettingsStorage.saveGlobalSettingsToFile(GlobalSettings(lastUniqueGeneratedID: globals.lastUniqueGeneratedID, popUpMessagesEnabled: globals.popUpMessagesEnabled, compactTaskListViewEnabled: globals.compactTaskListViewEnabled, alwaysShowExpiredTasks: globals.alwaysShowExpiredTasks, autoMonthOldDelete: globals.autoMonthOldDelete));
                                          Navigator.of(context).pop();
                                        });
                                      },
                                      child: Text(
                                        globals.compactTaskListViewEnabled ? "Keep enabled" : "Enable",
                                        style: const TextStyle(fontSize: 19, color: Colors.black),
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
              const Divider(
                height: 4,
              ),
              ListTile(
                title: Row(
                  children: [
                    globals.alwaysShowExpiredTasks
                        ? const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          )
                        : const Icon(
                            Icons.cancel,
                            color: Colors.red,
                          ),
                    Text(globals.alwaysShowExpiredTasks ? ' Show expired tasks: Yes' : ' Show expired tasks: No'),
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
                                const Text("Show Expired Tasks"),
                              ],
                            ),
                            content: const Text('This option enables/disables expired tasks visualization under currently filtered tasks (only in list view).', textAlign: TextAlign.center),
                            actions: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          globals.alwaysShowExpiredTasks = false;
                                          debugPrint("Show Expried Tasks disabled");
                                          globals.globalSettingsStorage.saveGlobalSettingsToFile(GlobalSettings(lastUniqueGeneratedID: globals.lastUniqueGeneratedID, popUpMessagesEnabled: globals.popUpMessagesEnabled, compactTaskListViewEnabled: globals.compactTaskListViewEnabled, alwaysShowExpiredTasks: globals.alwaysShowExpiredTasks, autoMonthOldDelete: globals.autoMonthOldDelete));
                                          Navigator.of(context).pop();
                                        });
                                      },
                                      child: Text(
                                        globals.alwaysShowExpiredTasks ? "Disable" : "Keep disabled",
                                        style: const TextStyle(fontSize: 19, color: Colors.black),
                                      ),
                                      style: TextButton.styleFrom(backgroundColor: Colors.redAccent),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          globals.alwaysShowExpiredTasks = true;
                                          debugPrint("Show Expired Tasks enabled");
                                          globals.globalSettingsStorage.saveGlobalSettingsToFile(GlobalSettings(lastUniqueGeneratedID: globals.lastUniqueGeneratedID, popUpMessagesEnabled: globals.popUpMessagesEnabled, compactTaskListViewEnabled: globals.compactTaskListViewEnabled, alwaysShowExpiredTasks: globals.alwaysShowExpiredTasks, autoMonthOldDelete: globals.autoMonthOldDelete));
                                          Navigator.of(context).pop();
                                        });
                                      },
                                      child: Text(
                                        globals.alwaysShowExpiredTasks ? "Keep enabled" : "Enable",
                                        style: const TextStyle(fontSize: 19, color: Colors.black),
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
              const Divider(
                height: 4,
              ),
              ListTile(
                title: Row(
                  children: [
                    globals.autoMonthOldDelete
                        ? const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          )
                        : const Icon(
                            Icons.cancel,
                            color: Colors.red,
                          ),
                    Text(globals.autoMonthOldDelete ? ' Auto-Delete 1 month old tasks: Yes' : ' Auto-Delete 1 month old tasks: No'),
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
                                const Text("Auto-Delete Old Tasks"),
                              ],
                            ),
                            content: const Text('This option enables/disables expired tasks automatic deletion. Tasks will be deleted when at least 1 month old.', textAlign: TextAlign.center),
                            actions: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          globals.autoMonthOldDelete = false;
                                          debugPrint("Auto-Delete Old Tasks disabled");
                                          globals.globalSettingsStorage.saveGlobalSettingsToFile(GlobalSettings(lastUniqueGeneratedID: globals.lastUniqueGeneratedID, popUpMessagesEnabled: globals.popUpMessagesEnabled, compactTaskListViewEnabled: globals.compactTaskListViewEnabled, alwaysShowExpiredTasks: globals.alwaysShowExpiredTasks, autoMonthOldDelete: globals.autoMonthOldDelete));
                                          Navigator.of(context).pop();
                                        });
                                      },
                                      child: Text(
                                        globals.autoMonthOldDelete ? "Disable" : "Keep disabled",
                                        style: const TextStyle(fontSize: 19, color: Colors.black),
                                      ),
                                      style: TextButton.styleFrom(backgroundColor: Colors.redAccent),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          globals.autoMonthOldDelete = true;
                                          debugPrint("Auto-Delete Old Tasks enabled");
                                          globals.globalSettingsStorage.saveGlobalSettingsToFile(GlobalSettings(lastUniqueGeneratedID: globals.lastUniqueGeneratedID, popUpMessagesEnabled: globals.popUpMessagesEnabled, compactTaskListViewEnabled: globals.compactTaskListViewEnabled, alwaysShowExpiredTasks: globals.alwaysShowExpiredTasks, autoMonthOldDelete: globals.autoMonthOldDelete));
                                          Navigator.of(context).pop();
                                        });
                                      },
                                      child: Text(
                                        globals.autoMonthOldDelete ? "Keep enabled" : "Enable",
                                        style: const TextStyle(fontSize: 19, color: Colors.black),
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
            ],
          ),
        ),
        body: Stack(
          children: <Widget>[
            selectViewModeMainWidget(),
            UserSelectionDropUpWidget(
              actuallySelectedUser: selectedUser!,
              key: userSelectionDropUpKey,
              onUserSelected: (User user) {
                debugPrint(" > User filter changed to: " + user.name);
                selectedUser = user;
                rebuildMainScreen(false, false);
              },
            ),
          ],
        ));
  }

  Future<void> _wipeAllData() async {
    // Wipe data...
    await globals.categoriesStorage.saveCategoriesToFile([]);
    await globals.tasksStorage.saveTasksToFile([]);
    await globals.usersStorage.saveUsersToFile([]);
    await globals.rankHistoryStorage.saveRankHistoryToFile([]);
    GlobalSettings wipedSettings = GlobalSettings(lastUniqueGeneratedID: 0, popUpMessagesEnabled: true, compactTaskListViewEnabled: false, alwaysShowExpiredTasks: true, autoMonthOldDelete: true);
    await globals.globalSettingsStorage.saveGlobalSettingsToFile(wipedSettings);

    // Deleting all users pictures
    final directory = await getApplicationDocumentsDirectory();
    if (await Directory(directory.path + "/user_images/").existsSync()) {
      await new Directory(directory.path + "/user_images/").delete(recursive: true);
    }
    await new Directory(directory.path + "/user_images/").create(recursive: true);

    await LocalNoticeService().cancelAllNotifications();

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
          style: const TextStyle(color: Colors.white, fontSize: 15),
        )),
      );
    } else {
      return Container(
        height: 0,
      );
    }
  }

  Widget _listModeMainWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          height: 45,
          child: CategoryHorizontalListView(
            categories: globals.categories,
            onChange: (Category val) {
              selectedCategory = val;
              rebuildMainScreen(false, false);
            },
          ),
        ),
        _additionalUserWidgetText(),
        Expanded(
          child: _tasksPageMainWidgetBuilder(context, rebuildMainScreen, completeTaskCallback, TaskFilter(startingDate: selectedStartingDate!, endDate: selectedEndDate, category: selectedCategory, user: selectedUser)),
        ),
      ],
    );
  }

  Widget selectViewModeMainWidget() {
    if (viewMode == "list") {
      return _listModeMainWidget();
    } else {
      return _calendarModeMainWidget();
    }
  }

  Widget _calendarModeMainWidget() {
    return Column(
      children: [
        SizedBox(
          height: 45,
          child: CategoryHorizontalListView(
            categories: globals.categories,
            onChange: (Category val) {
              selectedCategory = val;
              rebuildMainScreen(false, false);
            },
          ),
        ),
        SizedBox(
          child: CalendarDatePicker2(
            config: CalendarDatePicker2Config(
              calendarType: CalendarDatePicker2Type.range,
              selectedDayHighlightColor: Colors.amber,
              dayTextStyle: const TextStyle(color: Colors.white),
              selectedDayTextStyle: const TextStyle(color: Colors.black),
              controlsTextStyle: const TextStyle(color: Colors.white, fontSize: 17),
              weekdayLabelTextStyle: const TextStyle(color: Colors.white, fontSize: 17),
              todayTextStyle: const TextStyle(color: Colors.amber),
              yearTextStyle: const TextStyle(color: Colors.white),
              disableYearPicker: true,
            ),
            onValueChanged: (dates) {
              setState(() {
                debugPrint("> Calendar view, new dates selected: " + dates.toString());

                if (dates.isNotEmpty) {
                  if (dates.length == 2) {
                    selectedStartingDate = dates[0];
                    selectedEndDate = dates[1];
                  } else {
                    selectedStartingDate = dates[0];
                    selectedEndDate = null;
                  }

                  calendarRangeSelectedCallback(dates);
                }
              });
            },
            initialValue: [selectedStartingDate, selectedEndDate],
          ),
        ),
        _additionalUserWidgetText(),
        Expanded(
          child: _tasksPageMainWidgetBuilder(context, rebuildMainScreen, completeTaskCallback, TaskFilter(startingDate: selectedStartingDate!, endDate: selectedEndDate, category: selectedCategory, user: selectedUser)),
        ),
      ],
    );
  }

  void calendarRangeSelectedCallback(List<DateTime?> dates) {
    selectedTimeOption = "Custom Interval";
  }
}

List<Widget> listOfTaskBuilder(BuildContext context, void Function(bool restoreSelectedUser, bool restoreSelectedCategory) rebuildMainScreenCallback, void Function(Task) taskCompletedCallback, List<Task> filteredTasks) {
  List<Widget> taskTiles = [];

  for (var i = 0; i < filteredTasks.length; i++) {
    Widget taskTile = TaskTileWidget(
      task: filteredTasks[i],
      onChange: () {
        rebuildMainScreenCallback(false, false);
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
  MainScreenAdditionalOptionsDropdown({Key? key, required this.rebuildMainScreenCallback(bool restoreSelectedUser, bool restoreSelectedCategory)}) : super(key: key);

  void Function(bool restoreSelectedUser, bool restoreSelectedCategory) rebuildMainScreenCallback;

  @override
  State<MainScreenAdditionalOptionsDropdown> createState() => MainScreenAdditionalOptionsDropdownState();
}

class MainScreenTimeIntervalSelectionDropdown extends StatefulWidget {
  const MainScreenTimeIntervalSelectionDropdown({Key? key, required this.onChange, required this.viewMode, required this.startingSelectedValue, required this.startingCustomInterval, required this.onSelection}) : super(key: key);

  final DateTimeRangeCallback onChange;
  final StringCallback onSelection;
  final String viewMode;
  final String startingSelectedValue;
  final List<DateTime?> startingCustomInterval;

  @override
  State<MainScreenTimeIntervalSelectionDropdown> createState() => MainScreenTimeIntervalSelectionDropdownState();
}

typedef void DateTimeRangeCallback(List<DateTime?> val);

class MainMenuBottomNavBar extends StatefulWidget {
  final GlobalKey? userDropUpWidgetKey;
  final Function? showUserDropUpFunction;
  final StringCallback changedViewModeCallback;

  const MainMenuBottomNavBar({Key? key, this.userDropUpWidgetKey, this.showUserDropUpFunction, required this.changedViewModeCallback}) : super(key: key);

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
            if (value == 1) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoriesScreen())).then((_) => setState(() {
                    widget.rebuildMainScreenCallback(false, false);
                  }));
            }
            if (value == 2) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => UserScreen())).then((_) => setState(() {
                    widget.rebuildMainScreenCallback(true, false);
                  }));
            }
          });
        },
        itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text("Manage Categories"),
                value: 1,
                onTap: () {},
              ),
              PopupMenuItem(
                child: const Text("Manage Users"),
                value: 2,
                onTap: () {},
              ),
            ]);
  }
}

Widget _tasksPageMainWidgetBuilder(context, void Function(bool restoreSelectedUser, bool restoreSelectedCategory) callback, void Function(Task) completeTaskCallback, TaskFilter selectionFilter) {
  List<Task> filteredTasks = getSelectedTasksList(selectionFilter);
  List<Task> expiredTasks = getExpiredTasksList(selectionFilter);

  bool isExpiredOptionSelected = DateTime(0).toString() == selectionFilter.startingDate.toString();

  List<Widget> expiredTasksWidgets = isExpiredOptionSelected == false ? _expiredTasksWidgetBuilder(context, callback, completeTaskCallback, selectionFilter) : [];
  List<Widget> filteredTasksWidgets = listOfTaskBuilder(context, callback, completeTaskCallback, filteredTasks);

  if (filteredTasks.isNotEmpty) {
    if (globals.activeViewMode == "list") {
      return ListView(
        shrinkWrap: true,
        children: filteredTasksWidgets + expiredTasksWidgets,
      );
    } else {
      return ListView(
        shrinkWrap: true,
        children: filteredTasksWidgets,
      );
    }
  } else if (filteredTasks.isEmpty && (globals.alwaysShowExpiredTasks == true && expiredTasks.isNotEmpty)) {
    if (globals.activeViewMode == "list") {
      return ListView(
        children: [_noTasksWidgetBuilder(context)] + expiredTasksWidgets,
      );
    } else {
      return ListView(
        children: [_noTasksWidgetBuilder(context)],
      );
    }
  } else {
    return Column(
      children: [
        globals.activeViewMode == "list"
            ? Container(
                height: MediaQuery.of(context).size.height * 0.175,
              )
            : Container(
                height: 0,
              ),
        _noTasksWidgetBuilder(context),
      ],
    );
  }
}

List<Widget> _expiredTasksWidgetBuilder(context, void Function(bool restoreSelectedUser, bool restoreSelectedCategory) callback, void Function(Task p1) completeTaskCallback, TaskFilter selectionFilter) {
  if (globals.alwaysShowExpiredTasks == true) {
    List<Task> expiredTasks = getExpiredTasksList(selectionFilter);
    if (expiredTasks.isNotEmpty) {
      List<Widget> widgets = [
        Container(height: 20),
        Container(height: 2, color: Colors.amber),
        Container(height: 10),
        const Text(
          "🕟 Expired Tasks:",
          style: TextStyle(fontSize: 15, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        Container(height: 10),
      ];

      return widgets + listOfTaskBuilder(context, callback, completeTaskCallback, expiredTasks);
    } else {
      return [];
    }
  } else {
    return [];
  }
}

Widget _noTasksWidgetBuilder(context) {
  return Container(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: globals.activeViewMode == "list" ? EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.05) : const EdgeInsets.all(0),
          child: const Text("No Tasks Found!", style: TextStyle(fontSize: 24, color: Colors.white)),
        ),
        const Padding(
          padding: EdgeInsets.all(10),
          child: Center(
            child: Text("🔍",
                style: TextStyle(
                  fontSize: 45, // !!! WARNING: if too big: BUG on RENDER
                )),
          ),
        ),
        Padding(
          padding: globals.activeViewMode != "list" ? EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.25) : EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.10),
          child: const Text(
            "There are no tasks matching the currently\nselected filters! You can rest 💤",
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    ),
  );
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
        widget.changedViewModeCallback("list");
      }
      if (index == 2) {
        debugPrint("Switch to calendar view");
        widget.changedViewModeCallback("calendar");
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
  List<DateTime?> customInterval = [];
  String dropdownValue = 'Today';

  @override
  Widget build(BuildContext context) {
    customInterval = widget.startingCustomInterval;
    dropdownValue = widget.startingSelectedValue;
    return Padding(
      padding: const EdgeInsets.all(7.0),
      child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
              value: dropdownValue,
              icon: const Icon(Icons.arrow_drop_down),
              onChanged: (String? newValue) async {
                var oldValue = dropdownValue;
                dropdownValue = newValue!;
                List<DateTime?> dates = await _getTimeRangeFromSelectedInterval(dropdownValue);
                if (dates.isEmpty) {
                  dropdownValue = oldValue;
                  widget.onChange(dates);
                } else {
                  widget.onChange(dates);
                }
                if (dropdownValue == "Custom Interval" && dates.isNotEmpty) {
                  customInterval = dates;
                }

                widget.onSelection(dropdownValue);
              },
              items: selectedMainScreenTimeIntervalSelectionDropdownItems(widget.viewMode))),
    );
  }

  Future<List<DateTime?>> _getTimeRangeFromSelectedInterval(String value) async {
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
      case "Expired":
        return [DateTime(0), DateTime.now().subtract(const Duration(days: 1))];
      case "Custom Interval":
        return await _dateTimeRangeSelection();
      default:
        return [];
    }
  }

  Future<List<DateTime?>> _dateTimeRangeSelection() async {
    DateTime today = DateTime.now();
    DateTimeRange dateRange;
    if (customInterval.isEmpty) {
      dateRange = DateTimeRange(start: today, end: DateTime(today.year, today.month, today.day + 4));
    } else if (customInterval.length == 2 && customInterval[1] != null) {
      dateRange = DateTimeRange(start: customInterval[0]!, end: customInterval[1]!);
    } else {
      dateRange = DateTimeRange(start: customInterval[0]!, end: customInterval[0]!);
    }

    var newDateRange = await showCalendarDatePicker2Dialog(
      context: context,
      config: CalendarDatePicker2WithActionButtonsConfig(
        calendarType: CalendarDatePicker2Type.range,
        selectedDayHighlightColor: Colors.amber,
        dayTextStyle: const TextStyle(color: Colors.black),
        selectedDayTextStyle: const TextStyle(color: Colors.white),
        controlsTextStyle: const TextStyle(color: Colors.black, fontSize: 17),
        weekdayLabelTextStyle: const TextStyle(color: Colors.black, fontSize: 17),
        todayTextStyle: const TextStyle(color: Colors.amber),
      ),
      dialogSize: const Size(325, 400),
      initialValue: [],
      borderRadius: BorderRadius.circular(15),
    );

    if (newDateRange == null) {
      return [];
    } else {
      return newDateRange;
    }
  }

  List<DropdownMenuItem<String>> selectedMainScreenTimeIntervalSelectionDropdownItems(String viewMode) {
    List<DropdownMenuItem<String>> items = [
      const DropdownMenuItem(
          child: Text(
            "Today",
            style: TextStyle(fontSize: 18),
          ),
          value: "Today"),
      const DropdownMenuItem(
          child: Text(
            "Tomorrow",
            style: TextStyle(fontSize: 18),
          ),
          value: "Tomorrow"),
      const DropdownMenuItem(
          child: Text(
            "This Week",
            style: TextStyle(fontSize: 18),
          ),
          value: "This Week"),
      const DropdownMenuItem(
          child: Text(
            "This Month",
            style: TextStyle(fontSize: 18),
          ),
          value: "This Month"),
      const DropdownMenuItem(
          child: Text(
            "Expired",
            style: TextStyle(fontSize: 18),
          ),
          value: "Expired"),
    ];

    if (viewMode == "list") {
      items.add(DropdownMenuItem(child: _getCustomIntervalDropDownActiveText(dropdownValue, customInterval), value: "Custom Interval"));
    }
    return items;
  }
}

Widget _getCustomIntervalDropDownActiveText(String dropdownValue, List<DateTime?> customInterval) {
  TextStyle style = const TextStyle(fontSize: 18, fontWeight: FontWeight.w400);

  if (dropdownValue != "Custom Interval") {
    return Text("Custom Interval", style: style);
  } else if (customInterval.length == 0) {
    return const Text("Custom Interval");
  } else if (customInterval[1] == null || monthToText(customInterval[0]!.month) == monthToText(customInterval[1]!.month) && customInterval[0]!.day.toString() == customInterval[1]!.day.toString()) {
    return Text(monthToText(customInterval[0]!.month, extendedMode: true) + " " + customInterval[0]!.day.toString(), style: style);
  } else {
    return Text(monthToText(customInterval[0]!.month) + " " + customInterval[0]!.day.toString() + " - " + monthToText(customInterval[1]!.month) + " " + customInterval[1]!.day.toString(), style: style);
  }
}

Widget _getCalendarViewActiveText(List<DateTime?> customInterval) {
  TextStyle style = const TextStyle(fontSize: 18, fontWeight: FontWeight.w400);
  if (customInterval[1] == null) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        monthToText(customInterval[0]!.month, extendedMode: true) + " " + customInterval[0]!.day.toString(),
        style: style,
      ),
    );
  } else if (monthToText(customInterval[0]!.month) == monthToText(customInterval[1]!.month) && customInterval[0]!.day.toString() == customInterval[1]!.day.toString()) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(monthToText(customInterval[0]!.month, extendedMode: true) + " " + customInterval[0]!.day.toString(), style: style),
    );
  } else {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(monthToText(customInterval[0]!.month) + " " + customInterval[0]!.day.toString() + " - " + monthToText(customInterval[1]!.month) + " " + customInterval[1]!.day.toString(), style: style),
    );
  }
}
