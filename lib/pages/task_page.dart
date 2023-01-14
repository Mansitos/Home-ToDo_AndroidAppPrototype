import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:home_to_do/custom_widgets/custom_interval_form_dialog.dart';
import 'package:home_to_do/custom_widgets/pop_up_message.dart';
import 'package:home_to_do/custom_widgets/score_selection_widget.dart';
import 'package:home_to_do/data_types/category.dart';
import 'package:home_to_do/data_types/task.dart';
import 'package:home_to_do/data_types/user.dart';
import 'package:home_to_do/utilities/categories_utilities.dart';
import 'package:home_to_do/utilities/generic_utilities.dart';
import 'package:home_to_do/utilities/globals.dart' as globals;
import 'package:home_to_do/utilities/task_utilities.dart';
import 'package:home_to_do/utilities/users_utilities.dart';

// Main Widget of the Main Page
class TaskScreen extends StatefulWidget {
  TaskScreen({Key? key, this.mode, this.taskToModify}) : super(key: key);

  String? mode;
  Task? taskToModify;

  @override
  State<TaskScreen> createState() => TaskScreenState();
}

class TaskScreenState extends State<TaskScreen> {
  Category startingSelectedCategory = globals.categories[0];
  TimeOfDay startingSelectedHour = TimeOfDay.now().plusMinutes(60);
  DateTime startingSelectedDate = _getStartingDate(TimeOfDay.now().plusMinutes(60));
  int startingSelectedScore = 3;
  User startingSelectedUser = globals.users[0];
  String startingSelectedRepeat = "No";
  bool startingSelectedNotification = false;

  String? selectedName;
  String? selectedDescription;
  Category? selectedCategory;
  DateTime? selectedDate;
  TimeOfDay? selectedHour;
  int? selectedScore;
  User? selectedUser;
  String? selectedRepeat;
  bool? selectedNotification;

  int? customDayInterval;

  MediaQueryData? queryData;
  double screenWidth = 0;
  double screenHeight = 0;

  void updateSelectedScore(int newScore) {
    setState(() {
      selectedScore = newScore;
    });
  }

  // Date selection pop-up widget
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.dark(
                primary: Colors.amber,
                onPrimary: Colors.black,
                onSurface: Colors.black,
                surface: Colors.white,
              ),
              textSelectionTheme: TextSelectionThemeData(
                selectionColor: Colors.amber,
                cursorColor: Colors.black,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black, // button text color
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
      if (picked != null) {
        selectedDate = picked;
        debugPrint(selectedDate.toString() + " selected!");
      }
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
              textSelectionTheme: TextSelectionThemeData(
                selectionColor: Colors.amber,
                cursorColor: Colors.black,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                ),
              ),
            ),
            child: child!,
          );
        },
        context: context,
        initialTime: _getSelectedHour()!);
    setState(() {
      if (picked != null) {
        selectedHour = picked;

        if (_getSelectedDate()!.year == DateTime.now().year && _getSelectedDate()!.month == DateTime.now().month && _getSelectedDate()!.day == DateTime.now().day) {
          if (picked.hour < TimeOfDay.now().hour) {
            // past date...
            selectedHour = TimeOfDay.now().plusMinutes(1);
          } else if (picked.hour == TimeOfDay.now().hour && picked.minute < TimeOfDay.now().minute) {
            // past date
            selectedHour = TimeOfDay.now().plusMinutes(1);
          } else {
            // ok case!
          }
        }
        debugPrint(selectedHour.toString() + " selected!");
      }
    });
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    if (widget.mode == "Modify") {
      _initializeModifyModeValues(widget.taskToModify!);
    }

    queryData = MediaQuery.of(context);
    screenWidth = queryData!.size.width;
    screenHeight = queryData!.size.height;

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
                        selectedCategory: _getSelectedCategory()!.toString(),
                        onChange: (Category val) {
                          setState(() {
                            selectedCategory = val;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: TextFormField(
                      initialValue: selectedName,
                      onSaved: (String? value) {
                        setState(() {});
                      },
                      onChanged: (String? value) {
                        selectedName = value;
                      },
                      maxLength: globals.taskNameMaxLen,
                      validator: (String? value) {
                        final validCharacters = globals.taskNameValidChars;
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text!';
                        } else if (!validCharacters.hasMatch(value.replaceAll(' ', ''))) {
                          return 'Invalid characters!';
                        } else {
                          selectedName = value;
                          return null;
                        }
                      },
                      style: const TextStyle(fontSize: 18),
                      decoration: const InputDecoration(hintText: "Insert task name...", labelText: "Task name", labelStyle: TextStyle(color: Colors.white), hintStyle: TextStyle(color: Colors.white), counterStyle: TextStyle(color: Colors.white))),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                  child: TextFormField(
                      initialValue: selectedDescription,
                      onSaved: (String? value) {
                        setState(() {});
                      },
                      onChanged: (String? value) {
                        selectedDescription = value;
                      },
                      maxLength: globals.taskDescMaxLen,
                      validator: (String? value) {
                        final validCharacters = globals.taskDescValidChars;
                        if (value == null || value.isEmpty) {
                          selectedDescription = "";
                          return null;
                        } else if (!validCharacters.hasMatch(value.replaceAll(' ', ''))) {
                          return 'Invalid characters!';
                        } else {
                          selectedDescription = value;
                          return null;
                        }
                      },
                      style: const TextStyle(fontSize: 18),
                      decoration: const InputDecoration(hintText: "Insert task description...", labelText: "Task description", labelStyle: TextStyle(color: Colors.white), hintStyle: TextStyle(color: Colors.white), counterStyle: TextStyle(color: Colors.white))),
                ),
                const Divider(
                  height: 8,
                ),
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
                        Container(
                          height: screenHeight * 0.0425,
                          child: ElevatedButton(
                              onPressed: () {
                                _selectDate(context);
                              },
                              child: Text(_dateToString(_getSelectedDate()!))),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(
                  height: 8,
                ),
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
                      Container(
                        height: screenHeight * 0.0425,
                        child: ElevatedButton(
                            onPressed: () {
                              _selectHour(context);
                            },
                            child: Text(_hourToString(_getSelectedHour()!))),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  height: 8,
                ),
                ListTile(
                  leading: const Icon(
                    Icons.repeat,
                    color: Colors.white,
                  ),
                  title: DropDownRepeat(
                    onChange: (String val) {
                      selectedRepeat = val;
                      setState(() {});
                    },
                    selectedRepeat: _getSelectedRepeat()!,
                    customDayIntervalChange: (int val) {
                      customDayInterval = val;
                    },
                    customDayInterval: customDayInterval,
                    mode: widget.mode!,
                  ),
                ),
                const Divider(
                  height: 8,
                ),
                ListTile(
                  leading: const Icon(
                    Icons.notifications,
                    color: Colors.white,
                  ),
                  title: const Text(
                    'Notification',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: screenHeight * 0.0425,
                        child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                selectedNotification = !_getSelectedNotification()!;
                                debugPrint("Notification selection: " + selectedNotification.toString());
                              });
                            },
                            child: Text(_boolToYesNo(_getSelectedNotification()))),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  height: 8,
                ),
                ListTile(
                  leading: const Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                  title: DropDownUsers(
                    onChange: (User val) {
                      setState(() {
                        selectedUser = val;
                      });
                    },
                    selectedUser: _getSelectedUser()!,
                  ),
                ),
                const Divider(
                  height: 8,
                ),
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
                        updateSelectedScore(val);
                        debugPrint("score selected for task:" + selectedScore.toString());
                      });
                    },
                  ),
                ),
                const Divider(
                  height: 8,
                ),
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
                              createNewTask(selectedName!, selectedDescription!, _getSelectedCategory()!, _getSelectedDate()!, _getSelectedHour()!, _getSelectedScore()!, _getSelectedUser()!, _getSelectedRepeat()!, _getSelectedNotification()!);
                            });
                          }
                          if (widget.mode == "Add") {
                            showPopUpMessage(context, _getRandomConfirmationEmoji(), "Task Created!", null, additionalPops: 1);
                          } else if (widget.mode == "Modify") {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("📝 Confirm Task Changes?"),
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
                                                modifyTask(widget.taskToModify!, selectedName!, selectedDescription!, _getSelectedCategory()!, _getSelectedDate()!, _getSelectedHour()!, _getSelectedScore()!, _getSelectedUser()!, _getSelectedRepeat()!, _getSelectedNotification()!);
                                                Navigator.of(context).pop();
                                                showPopUpMessage(context, "✅", "Task Modified!", null, additionalPops: 1);
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

  User? _getSelectedUser() {
    if (selectedUser == null) {
      return startingSelectedUser;
    } else {
      return selectedUser;
    }
  }

  bool? _getSelectedNotification() {
    if (selectedNotification == null) {
      return startingSelectedNotification;
    } else {
      return selectedNotification;
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

  String? _getSelectedRepeat() {
    if (selectedRepeat == null) {
      return startingSelectedRepeat;
    } else if (customDayInterval == 0) {
      return selectedRepeat;
    } else if (customDayInterval != 0) {
      return customDayInterval.toString();
    }
  }

  String _dateToString(DateTime date) {
    return date.day.toString() + "/" + date.month.toString() + "/" + date.year.toString();
  }

  Category? _getSelectedCategory() {
    if (selectedCategory == null) {
      return startingSelectedCategory;
    } else {
      return selectedCategory;
    }
  }

  void _initializeModifyModeValues(Task task) {
    selectedName = task.name;
    selectedDescription = task.description;
    startingSelectedCategory = task.category;
    startingSelectedDate = task.dateLimit;
    startingSelectedHour = task.timeLimit;
    startingSelectedScore = task.score;
    startingSelectedUser = task.user;
    startingSelectedRepeat = task.repeat;
    startingSelectedNotification = task.notification;
  }

  int? _getSelectedScore() {
    if (selectedScore == null) {
      return startingSelectedScore;
    } else {
      return selectedScore;
    }
  }

  String _getRandomConfirmationEmoji() {
    List<String> confirmationEmojis = ["🚀", "👌", "👍", "🎉", "😄", "💪", "🎉" "⚡", "✅", "✅", "✅", "✅", "✅", "✅", "✅"];
    return confirmationEmojis[Random().nextInt(confirmationEmojis.length)];
  }

  static DateTime _getStartingDate(TimeOfDay startingTime) {
    if (startingTime.hour < TimeOfDay.now().hour) {
      return DateTime.now().add(Duration(days: 1));
    } else {
      return DateTime.now();
    }
  }
}

class CategoryDropDownSelector extends StatefulWidget {
  CategoryDropDownSelector({Key? key, required this.selectedCategory, required this.onChange}) : super(key: key);

  String selectedCategory;
  final categoryCallback onChange;

  @override
  State<CategoryDropDownSelector> createState() => CategoryDropDownSelectorState();
}

typedef void categoryCallback(Category val);
typedef void StringCallback(String val);
typedef void userCallback(User val);

class CategoryDropDownSelectorState extends State<CategoryDropDownSelector> {
  MediaQueryData? queryData;
  double screenHeight = 0;

  @override
  Widget build(BuildContext context) {
    queryData = MediaQuery.of(context);
    screenHeight = queryData!.size.height;

    return SizedBox(
      height: screenHeight * 0.0475,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(1000.0),
        ),
        child: DropdownButtonHideUnderline(
            child: Padding(
          padding: const EdgeInsets.only(left: 12, right: 2),
          child: DropdownButton<String>(
              style: const TextStyle(color: Colors.black, fontSize: 16),
              value: widget.selectedCategory,
              icon: Padding(
                padding: const EdgeInsets.all(3.0),
                child: const Icon(Icons.arrow_drop_down),
              ),
              onChanged: (String? newValue) {
                setState(() {
                  widget.selectedCategory = decodeSerializedCategory(newValue!).toString();
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
      items.add(
        DropdownMenuItem(child: Text(encoded), value: encoded),
      );
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
          child: Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Text(
              globals.users[i].name,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: color),
            ),
          ),
          value: encoded));
    }
  }
  return items;
}

class DropDownRepeat extends StatefulWidget {
  DropDownRepeat({Key? key, required this.onChange, required this.selectedRepeat, required this.customDayIntervalChange, required this.customDayInterval, required this.mode}) : super(key: key);

  final StringCallback onChange;
  String selectedRepeat;
  final intCallback customDayIntervalChange;
  int? customDayInterval;
  final String mode;

  @override
  State<DropDownRepeat> createState() => _DropDownRepeatState();
}

class DropDownUsers extends StatefulWidget {
  DropDownUsers({Key? key, required this.selectedUser, required this.onChange}) : super(key: key);

  User selectedUser;
  final userCallback onChange;

  final Color color = Colors.black;

  @override
  State<DropDownUsers> createState() => _DropDownUsersState();
}

class _DropDownRepeatState extends State<DropDownRepeat> {
  MediaQueryData? queryData;
  double screenHeight = 0;

  @override
  Widget build(BuildContext context) {
    queryData = MediaQuery.of(context);
    screenHeight = queryData!.size.height;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Repeat"),
        Container(
          height: screenHeight * 0.0425,
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
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  value: _getSelectedRepeatInitialValue(widget.mode),
                  icon: null,
                  underline: Container(
                    height: 0,
                  ),
                  onChanged: (String? newValue) async {
                    if (newValue == "No" || newValue == "Every Day" || newValue == "Every Week" || newValue == "Every Month") {
                      widget.selectedRepeat = newValue!;
                      widget.onChange(newValue);
                      widget.customDayIntervalChange(0);
                    } else {
                      debugPrint("Custom Interval Repeat Selection Procedure...");
                      if (widget.customDayInterval != null) {
                        await _customRepeatIntervalSelection(widget.customDayInterval!);
                      } else {
                        await _customRepeatIntervalSelection(3);
                      }
                    }
                    setState(() {});
                  },
                  onTap: () {},
                  items: repeatSelectionDropdownItems,
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Future<void> _customRepeatIntervalSelection(int startingValue) async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomIntervalDialogForm(
              startingDaysInterval: startingValue,
              onSelect: (int val) {
                widget.selectedRepeat = "Custom Interval";
                widget.onChange("Custom Interval");
                widget.customDayIntervalChange(val);
                setState(() {});
              },
            );
          });
    });
  }

  List<DropdownMenuItem<String>> get repeatSelectionDropdownItems {
    TextStyle textStyle = TextStyle(fontSize: 16, color: Colors.black);

    List<DropdownMenuItem<String>> items = [
      DropdownMenuItem(
          child: Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Text("No", style: textStyle),
          ),
          value: "No"),
      DropdownMenuItem(
          child: Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Text("Every Day", style: textStyle),
          ),
          value: "Every Day"),
      DropdownMenuItem(
          child: Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Text("Every 7 Days", style: textStyle),
          ),
          value: "Every Week"),
      DropdownMenuItem(
          child: Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Text("Every 30 Days", style: textStyle),
          ),
          value: "Every Month"),
      DropdownMenuItem(
          child: Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Text(_getCustomIntervalText(), style: textStyle),
          ),
          value: "Custom Interval"),
    ];
    return items;
  }

  String _getCustomIntervalText() {
    if (widget.customDayInterval == null) {
      if (widget.mode != "Modify") {
        return "Custom Interval";
      } else {
        return "Every " + widget.selectedRepeat + " Days";
      }
    } else {
      return "Every " + widget.customDayInterval.toString() + " Days";
    }
  }

  _getSelectedRepeatInitialValue(String mode) {
    String rep = widget.selectedRepeat;
    if (rep != "No" && rep != "Every Day" && rep != "Every Week" && rep != "Every Month") {
      return "Custom Interval";
    } else {
      return rep;
    }
  }
}

class _DropDownUsersState extends State<DropDownUsers> {
  MediaQueryData? queryData;
  double screenHeight = 0;

  @override
  Widget build(BuildContext context) {
    queryData = MediaQuery.of(context);
    screenHeight = queryData!.size.height;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("User"),
        Container(
          height: screenHeight * 0.0425,
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
        )
      ],
    );
  }
}
