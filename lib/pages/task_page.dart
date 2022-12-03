import 'package:flutter/material.dart';
import 'package:home_to_do/custom_widgets/score_selection_widget.dart';
import 'package:home_to_do/data_types/category.dart';
import 'package:home_to_do/data_types/user.dart';
import 'package:home_to_do/utilities/categories_utilities.dart';
import 'package:home_to_do/utilities/globals.dart' as globals;
import 'package:home_to_do/utilities/task_utilities.dart';

class TaskScreen extends StatefulWidget {
  String? mode;

  TaskScreen({Key? key, this.mode}) : super(key: key);

  @override
  State<TaskScreen> createState() => TaskScreenState();
}

class TaskScreenState extends State<TaskScreen> {
  Category startingTaskCategory = globals.categories[0];
  DateTime startingSelectedDate = DateTime.now();
  TimeOfDay startingSelectedHour = TimeOfDay.now();
  bool startingReminder = false;

  String? taskName;
  String? taskDescription;
  Category? taskCategory;
  DateTime? selectedDate;
  TimeOfDay? selectedHour;
  bool? reminder;
  int score = 3; // the value is the default one

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
                  title: const Text(
                    'Luca',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
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
                    startingScore: score,
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
                          setState(() {
                            " > New task form validated!";
                            //TODO: distinguish mode modify and create
                            createNewTask(taskName!, taskDescription!, _getSelectedCategory()!, _getSelectedDate()!,_getSelectedHour()!, score, User(name: "placeholder_user"));
                            // TODO: animation of new task created (?)
                            _resetTaskForm();
                          });
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

  void _resetTaskForm() {
    taskName = null;
    taskDescription = null;
    taskCategory = null;
    selectedDate = null;
    selectedHour = null;
    reminder = false;
    score = 3;
  }

  bool? _getReminderValue() {
    if (reminder == null) {
      return startingReminder;
    } else {
      return reminder;
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
}

class CategoryDropDownSelector extends StatefulWidget {
  CategoryDropDownSelector({Key? key, required this.selectedCategory, required this.onChange}) : super(key: key);

  Category selectedCategory;
  final categoryCallback onChange;

  @override
  State<CategoryDropDownSelector> createState() => CategoryDropDownSelectorState();
}

typedef void categoryCallback(Category val);

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
              items: selectedTimeIntervalDropdownItems),
        )),
      ),
    );
  }
}

List<DropdownMenuItem<String>> get selectedTimeIntervalDropdownItems {
  List<DropdownMenuItem<String>> items = [];

  if (globals.categories.isNotEmpty) {
    for (var i = 0; i < globals.categories.length; i++) {
      String encoded = serializeCategory(globals.categories[i]);
      items.add(DropdownMenuItem(child: Text(encoded), value: encoded));
    }
  }
  return items;
}
