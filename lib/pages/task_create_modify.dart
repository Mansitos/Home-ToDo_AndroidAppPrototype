import 'package:flutter/material.dart';

class TaskScreen extends StatefulWidget {
  String? mode;

  TaskScreen({Key? key, this.mode}) : super(key: key);

  @override
  State<TaskScreen> createState() => TaskScreenState();
}

class TaskScreenState extends State<TaskScreen> {
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // avoid keyboard to push up widgets
      drawerEnableOpenDragGesture: false, // disable gesture side_drawer opening
      appBar: AppBar(automaticallyImplyLeading: true, title: getTitleByMode(widget.mode)),
      body: Theme(
        data: Theme.of(context).copyWith(
          textTheme: Theme.of(context).textTheme.apply(bodyColor: Colors.white),
          dividerColor: Colors.white,
        ),
        child: Stack(children: <Widget>[
          ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: const [
                    CategoryDropDownSelector(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: TextFormField(
                    decoration: const InputDecoration(
                  hintText: "Insert task name...",
                  labelText: "Task name",
                  labelStyle: TextStyle(color: Colors.white),
                  hintStyle: TextStyle(color: Colors.white),
                )),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: TextFormField(
                    decoration: const InputDecoration(
                  hintText: "Insert task description...",
                  labelText: "Task description",
                  labelStyle: TextStyle(color: Colors.white),
                  hintStyle: TextStyle(color: Colors.white),
                )),
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
                            showDatePicker(
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
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.utc(3000, 12, 0));
                          },
                          child: Text("22/03/2022")),
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
                          showTimePicker(
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
                        },
                        child: Text("8:30")),
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
                    ElevatedButton(onPressed: () {}, child: Text("Yes")),
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
                  children: [],
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
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(onPressed: () {}, child: Text("3/5")),
                  ],
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
                        print("Cancel");
                      },
                      tooltip: "Cancel",
                      child: const Icon(Icons.cancel),
                    )),
                Align(
                  alignment: Alignment.bottomRight,
                  child: FloatingActionButton(
                    heroTag: "Confirm New/Modify_Task",
                    onPressed: () {
                      print("Confirm");
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
    );
  }

  getTitleByMode(mode) {
    if (mode == "Add") {
      return Text("New Task");
    } else if (mode == "Modify") {
      return Text("Modify Task");
    }
  }
}

class CategoryDropDownSelector extends StatefulWidget {
  const CategoryDropDownSelector({Key? key}) : super(key: key);

  @override
  State<CategoryDropDownSelector> createState() => CategoryDropDownSelectorState();
}

class CategoryDropDownSelectorState extends State<CategoryDropDownSelector> {
  String dropdownValue = "🏠 All";

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
              value: dropdownValue,
              icon: const Icon(Icons.arrow_drop_down),
              onChanged: (String? newValue) {
                setState(() {
                  dropdownValue = newValue!;
                });
              },
              items: selectedTimeIntervalDropdownItems),
        )),
      ),
    );
  }
}

List<DropdownMenuItem<String>> get selectedTimeIntervalDropdownItems {
  List<DropdownMenuItem<String>> items = const [
    DropdownMenuItem(child: Text("🏠 All"), value: "🏠 All"),
    DropdownMenuItem(child: Text("🌳 Garden"), value: "🌳 Garden"),
    DropdownMenuItem(child: Text("🍴 Kitchen"), value: "🍴 Kitchen"),
    DropdownMenuItem(child: Text("😽 Cat"), value: "😽 Cat"),
    DropdownMenuItem(child: Text("🚾 Bathroom"), value: "🚾 Bathroom"),
    DropdownMenuItem(child: Text("🍔 Food"), value: "🍔 Food"),
  ];
  return items;
}
