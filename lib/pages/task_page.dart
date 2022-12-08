import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:home_to_do/custom_widgets/pop_up_message.dart';
import 'package:home_to_do/custom_widgets/score_selection_widget.dart';
import 'package:home_to_do/data_types/category.dart';
import 'package:home_to_do/data_types/task.dart';
import 'package:home_to_do/data_types/user.dart';
import 'package:home_to_do/utilities/categories_utilities.dart';
import 'package:home_to_do/utilities/globals.dart' as globals;
import 'package:home_to_do/utilities/task_utilities.dart';
import 'package:home_to_do/utilities/users_utilities.dart';

class TaskScreen extends StatefulWidget {
  TaskScreen({Key? key, this.mode, this.taskToModify}) : super(key: key);

  String? mode;
  Task? taskToModify;

  @override
  State<TaskScreen> createState() => TaskScreenState();
}

class TaskScreenState extends State<TaskScreen> {
  Category startingTaskCategory = globals.categories[0];
  DateTime startingSelectedDate = DateTime.now();
  TimeOfDay startingSelectedHour = TimeOfDay.now();
  bool startingReminder = false;
  int startingScore = 3;
  User startingUser = globals.users[0];

  String? taskName;
  String? taskDescription;
  Category? taskCategory;
  DateTime? selectedDate;
  TimeOfDay? selectedHour;
  bool? reminder;
  int? score; // the value is the default one
  User? taskUser;

  void updateScore(int newScore) {
    setState(() {
      score = newScore;
    });
  }

  // Date selection pop-up widget
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  primary: Colors.black,
                ),
              ),
            ),
            child: child!,
          );
        },
        context: context,
        initialDate: _getSelectedDate()!,
        firstDate: DateTime.now(),
        lastDate: DateTime(2101));
    setState(() {
      selectedDate = picked!;
      //TODO: add validation?
      debugPrint(selectedDate.toString() + " selected!");
    });
  }

  // Hour selection pop-up widget
  Future<void> _selectHour(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Colors.black,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  primary: Colors.black,
                ),
              ),
            ),
            child: child!,
          );
        },
        context: context,
        initialTime: TimeOfDay.now());
    setState(() {
      selectedHour = picked!;
      //TODO: add validation? mi sa non serve perché di base c'è il min-start value da ora in poi
      debugPrint(selectedHour.toString() + " selected!");
    });
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    if (widget.mode == "Modify") {
      _initializeModifyModeValues(widget.taskToModify!);
    }

    return Scaffold(
      resizeToAvoidBottomInset: false, // avoid keyboard to push up widgets
      drawerEnableOpenDragGesture: false, // disable gesture side_drawer opening
      appBar: AppBar(automaticallyImplyLeading: true, title: getTitleByMode(widget.mode)),
      body: Theme(
        data: Theme.of(context).copyWith(
          textTheme: Theme.of(context).textTheme.apply(bodyColor: Colors.white),
          dividerColor: Colors.white,
        ),
        child: Form(
          key: _formKey,
          child: Stack(children: <Widget>[
            ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      CategoryDropDownSelector(
                        selectedCategory: _getSelectedCategory()!,
                        onChange: (Category val) {
                          setState(() {
                            taskCategory = val;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: TextFormField(
                      initialValue: taskName,
                      onSaved: (String? value) {
                        setState(() {});
                      },
                      onChanged: (String? value) {
                        taskName = value;
                      },
                      maxLength: 50,
                      validator: (String? value) {
                        final validCharacters = RegExp(r'^[a-zA-Z0-9]+$');
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text!';
                        } else if (!validCharacters.hasMatch(value.replaceAll(' ', ''))) {
                          return 'Invalid characters!';
                        } else {
                          taskName = value;
                          return null;
                        }
                      },
                      style: const TextStyle(fontSize: 18),
                      decoration: const InputDecoration(hintText: "Insert task name...", labelText: "Task name", labelStyle: TextStyle(color: Colors.white), hintStyle: TextStyle(color: Colors.white), counterStyle: TextStyle(color: Colors.white))),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: TextFormField(
                      initialValue: taskDescription,
                      onSaved: (String? value) {
                        setState(() {});
                      },
                      onChanged: (String? value) {
                        taskDescription = value;
                      },
                      maxLength: 150,
                      validator: (String? value) {
                        final validCharacters = RegExp(r'^[a-zA-Z0-9]+$');
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text!';
                        } else if (!validCharacters.hasMatch(value.replaceAll(' ', ''))) {
                          return 'Invalid characters!';
                        } else {
                          taskDescription = value;
                          return null;
                        }
                      },
                      style: const TextStyle(fontSize: 18),
                      decoration: const InputDecoration(hintText: "Insert task description...", labelText: "Task description", labelStyle: TextStyle(color: Colors.white), hintStyle: TextStyle(color: Colors.white), counterStyle: TextStyle(color: Colors.white))),
                ),
                const Divider(),
                SizedBox(
                  child: ListTile(
                    leading: const Icon(
                      Icons.calendar_today,
                      color: Colors.white,
                    ),
                    title: const Text(
                      'Expiration date',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              _selectDate(context);
                            },
                            child: Text(_dateToString(_getSelectedDate()!))),
                      ],
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(
                    Icons.access_time_filled,
                    color: Colors.white,
                  ),
                  title: const Text(
                    'Expiration time',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            _selectHour(context);
                          },
                          child: Text(_hourToString(_getSelectedHour()!))),
                    ],
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(
                    Icons.repeat,
                    color: Colors.white,
                  ),
                  title: const Text(
                    'Repeat',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(onPressed: () {}, child: Text("No")),
                    ],
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(
                    Icons.notifications,
                    color: Colors.white,
                  ),
                  title: const Text(
                    'Reminder',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            setState(() {
                              reminder = !_getReminderValue()!;
                              debugPrint("Reminder selection: " + reminder.toString());
                            });
                          },
                          child: Text(_boolToYesNo(_getReminderValue()))),
                    ],
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                  title: DropDownUsers(
                    onChange: (User val) {
                      setState(() {
                        taskUser = val;
                      });
                    },
                    selectedUser: _getSelectedUser()!,
                  ),

                ),
                const Divider(),
                ListTile(
                  leading: const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  title: const Text(
                    'Reward',
                  ),
                  trailing: ScoreSelection(
                    startingScore: _getSelectedScore()!,
                    formKey: _formKey,
                    onChange: (int val) {
                      setState(() {
                        updateScore(val);
                        debugPrint("score selected for task:" + score.toString());
                      });
                    },
                  ),
                ),
                const Divider(),
                Container(height: 75),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Stack(
                children: <Widget>[
                  Align(
                      alignment: Alignment.bottomLeft,
                      child: FloatingActionButton(
                        heroTag: "Cancel New/Modify_Task",
                        backgroundColor: Colors.redAccent,
                        onPressed: () {
                          debugPrint(" > Cancel New/Modify_Task button pressed!");
                          Navigator.of(context).pop();
                        },
                        tooltip: "Cancel",
                        child: const Icon(Icons.cancel),
                      )),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: FloatingActionButton(
                      heroTag: "Confirm New/Modify_Task",
                      onPressed: () {
                        debugPrint(" > Confirm New/Modify_Task button pressed!");
                        if (_formKey.currentState!.validate()) {
                          if (widget.mode == "Add") {
                            setState(() {
                              createNewTask(taskName!, taskDescription!, _getSelectedCategory()!, _getSelectedDate()!, _getSelectedHour()!, _getSelectedScore()!, _getSelectedUser()!);
                            });
                          }
                          if (widget.mode == "Add") {
                            showPopUpMessage(context, _getRandomConfirmationEmoji() + " Task created!", null, additionalPops: 1);
                          } else if (widget.mode == "Modify") {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("📝 Confirm task changes?"),
                                    actions: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            FloatingActionButton(
                                              heroTag: "UndoTaskModify",
                                              onPressed: () {
                                                setState(() {
                                                  debugPrint("Task modify cancelled!");
                                                  Navigator.of(context).pop();
                                                });
                                              },
                                              tooltip: "Cancel",
                                              backgroundColor: Colors.redAccent,
                                              child: const Icon(Icons.cancel),
                                            ),
                                            FloatingActionButton(
                                              heroTag: "ConfirmModify",
                                              onPressed: () {
                                                debugPrint("Task modify confirmed!");
                                                modifyTask(widget.taskToModify!, taskName!, taskDescription!, _getSelectedCategory()!, _getSelectedDate()!, _getSelectedHour()!, _getSelectedScore()!, _getSelectedUser()!);
                                                Navigator.of(context).pop();
                                                showPopUpMessage(context, "✅ Task modified!", null, additionalPops: 1);
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
                          }
                          //_resetTaskForm();
                          ;
                        }
                      },
                      tooltip: "Confirm",
                      child: const Icon(Icons.check),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  getTitleByMode(mode) {
    if (mode == "Add") {
      return Text("New Task");
    } else if (mode == "Modify") {
      return Text("Modify Task");
    }
  }

  String _hourToString(TimeOfDay selectedHour) {
    if (selectedHour.minute >= 10) {
      return selectedHour.hour.toString() + ":" + selectedHour.minute.toString();
    } else {
      return selectedHour.hour.toString() + ":0" + selectedHour.minute.toString();
    }
  }

  String _boolToYesNo(bool? reminder) {
    if (reminder == true) {
      return "Yes";
    } else {
      return "No";
    }
  }

  bool? _getReminderValue() {
    if (reminder == null) {
      return startingReminder;
    } else {
      return reminder;
    }
  }

  User? _getSelectedUser() {
    if (taskUser == null) {
      return startingUser;
    } else {
      return taskUser;
    }
  }

  TimeOfDay? _getSelectedHour() {
    if (selectedHour == null) {
      return startingSelectedHour;
    } else {
      return selectedHour;
    }
  }

  DateTime? _getSelectedDate() {
    if (selectedDate == null) {
      return startingSelectedDate;
    } else {
      return selectedDate;
    }
  }

  String _dateToString(DateTime date) {
    return date.day.toString() + "/" + date.month.toString() + "/" + date.year.toString();
  }

  Category? _getSelectedCategory() {
    if (taskCategory == null) {
      return startingTaskCategory;
    } else {
      return taskCategory;
    }
  }

  void _initializeModifyModeValues(Task task) {
    taskName = task.name;
    taskDescription = task.description;
    startingTaskCategory = task.category;
    startingSelectedDate = task.dateLimit;
    startingSelectedHour = task.timeLimit;
    startingReminder = false; // TODO: ee
    startingScore = task.score;
    startingUser = task.user;
  }

  int? _getSelectedScore() {
    if (score == null) {
      return startingScore;
    } else {
      return score;
    }
  }

  String _getRandomConfirmationEmoji() {
    List<String> confirmationEmojis = ["🚀", "👌", "👍", "🎉", "⚡", "✅", "✅", "✅", "✅", "✅"];
    return confirmationEmojis[Random().nextInt(confirmationEmojis.length)];
  }
}

class CategoryDropDownSelector extends StatefulWidget {
  CategoryDropDownSelector({Key? key, required this.selectedCategory, required this.onChange}) : super(key: key);

  Category selectedCategory;
  final categoryCallback onChange;

  @override
  State<CategoryDropDownSelector> createState() => CategoryDropDownSelectorState();
}

typedef void categoryCallback(Category val);
typedef void userCallback(User val);

class CategoryDropDownSelectorState extends State<CategoryDropDownSelector> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100.0),
        ),
        child: DropdownButtonHideUnderline(
            child: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: DropdownButton<String>(
              style: const TextStyle(color: Colors.black),
              value: serializeCategory(widget.selectedCategory),
              icon: const Icon(Icons.arrow_drop_down),
              onChanged: (String? newValue) {
                setState(() {
                  widget.selectedCategory = decodeSerializedCategory(newValue!);
                  widget.onChange(decodeSerializedCategory(newValue));
                });
              },
              items: selectedCategoryDropdownItems),
        )),
      ),
    );
  }
}

List<DropdownMenuItem<String>> get selectedCategoryDropdownItems {
  List<DropdownMenuItem<String>> items = [];

  if (globals.categories.isNotEmpty) {
    for (var i = 0; i < globals.categories.length; i++) {
      String encoded = serializeCategory(globals.categories[i]);
      items.add(DropdownMenuItem(child: Text(encoded), value: encoded),);
    }
  }
  return items;
}

List<DropdownMenuItem<String>> selectedUserDropdownItems(Color color) {
  List<DropdownMenuItem<String>> items = [];

  if (globals.users.isNotEmpty) {
    for (var i = 0; i < globals.users.length; i++) {
      String encoded = serializeUser(globals.users[i]);
      items.add(DropdownMenuItem(
          child: Text(
            globals.users[i].name,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: color),
          ),
          value: encoded));
    }
  }
  return items;
}

class DropDownUsers extends StatefulWidget {
  DropDownUsers({Key? key, required this.selectedUser, required this.onChange}) : super(key: key);

  User selectedUser;
  final userCallback onChange;
  Color color = Colors.black;

  @override
  State<DropDownUsers> createState() => _DropDownUsersState();
}

class _DropDownUsersState extends State<DropDownUsers> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("User"),
        Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 4.0, right: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              DropdownButton<String>(
                  //dropdownColor: const Color.fromRGBO(42, 42, 42, 1),
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  value: serializeUser(widget.selectedUser),
                  icon: null,
                  underline: Container(
                    height: 0,
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      widget.selectedUser = decodeSerializedUser(newValue!);
                      widget.onChange(decodeSerializedUser(newValue));
                    });
                  },
                  onTap: () {},
                  items: selectedUserDropdownItems(widget.color)),
            ],
          ),
        ),
        )],
    );
  }
}
