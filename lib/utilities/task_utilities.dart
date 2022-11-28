import 'package:flutter/cupertino.dart';
import 'package:home_to_do/data_types/category.dart';
import 'package:home_to_do/data_types/task.dart';
import 'package:home_to_do/data_types/user.dart';
import 'package:home_to_do/utilities/categories_utilities.dart';
import 'globals.dart' as globals;

Future<void> createNewTask(String name, String desc, Category cat, User user) async {
  Task newTask = Task(name: name, description: desc, category: cat, user: user);

  globals.tasks.add(newTask);
  debugPrint("\n > New task saved!\n" + serializeTask(newTask));
  await globals.tasksStorage.saveTasksToFile(globals.tasks);
}

Future<void> modifyTask(int index, String name, String desc, Category cat, User user) async {
  Task modifiedTask = Task(name: name, description: desc, category: cat, user: user);

  debugPrint("\n > Modify task with index " + index.toString());
  globals.tasks[index] = modifiedTask;
  debugPrint("Now tasks are: " + globals.tasks.toString());
  globals.tasksStorage.saveTasksToFile(globals.tasks);
}

Future<void> deleteTask(int index) async {
  debugPrint("\n > Delete task with index " + index.toString());
  globals.tasks.removeAt(index);
  debugPrint("Now tasks are: " + globals.tasks.toString());
  globals.tasksStorage.saveTasksToFile(globals.tasks);
}

Task decodeSerializedTask(String encode) {
  List<String> data = encode.split(';');
  String name = data[0];
  String desc = data[1];
  // date and hours TODO
  Category cat = decodeSerializedCategory(data[4]);
  User user = User(name: "temp"); // TODO decode and encode user data type

  return Task(name: name, description: desc, category: cat, user: user);
}

String serializeTask(Task task) {
  String sep = ';';
  String encoded_date = "date"; // TODO
  String encoded_hour = "hour"; // TODO
  String encoded_cat = serializeCategory(task.category);
  String encoded_user = "user"; // TODO
  return task.name + sep + task.description + sep + encoded_date + sep + encoded_hour + sep + encoded_cat + sep + encoded_user;
}
