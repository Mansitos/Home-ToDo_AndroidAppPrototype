import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_to_do/data_types/category.dart';
import 'package:home_to_do/data_types/task.dart';
import 'package:home_to_do/data_types/user.dart';
import 'package:home_to_do/utilities/categories_utilities.dart';
import 'globals.dart' as globals;

Future<void> createNewTask(String name, String desc, Category cat, DateTime date, TimeOfDay hour, int score, User user) async {
  Task newTask = Task(name: name, description: desc, category: cat, dateLimit: date, timeLimit: hour, score: score, user: user);

  globals.tasks.add(newTask);
  debugPrint("\n > New task saved!\n" + serializeTask(newTask));
  await globals.tasksStorage.saveTasksToFile(globals.tasks);
}

Future<void> modifyTask(int index, String name, String desc, Category cat, DateTime date, TimeOfDay hour, int score, User user) async {
  Task modifiedTask = Task(name: name, description: desc, category: cat, dateLimit: date, timeLimit: hour, score: score, user: user);

  debugPrint("\n > Modify task with index " + index.toString());
  globals.tasks[index] = modifiedTask;
  debugPrint("Now tasks are: " + globals.tasks.toString());
  globals.tasksStorage.saveTasksToFile(globals.tasks);
}

Future<void> deleteTaskByID(int id) async {
  debugPrint("\n > Delete task with ID:" + id.toString());
  for (var i = globals.tasks.length-1; i>=0; i--){
    if(globals.tasks[i].getID() == id){
      globals.tasks.removeAt(i);
    }
  }

  debugPrint("Now tasks are: " + globals.tasks.toString());
  globals.tasksStorage.saveTasksToFile(globals.tasks);
}

Task decodeSerializedTask(String encode) {
  List<String> data = encode.split(';');
  String name = data[0];
  String desc = data[1];
  // date and hours TODO
  Category cat = decodeSerializedCategory(data[4]);
  int score = int.parse(data[5]);
  User user = User(name: "temp"); // TODO decode and encode user data type

  return Task(name: name, description: desc, category: cat, score: score, user: user);
}

String serializeTask(Task task) {
  String sep = ';';
  String encoded_date = "date"; // TODO
  String encoded_hour = "hour"; // TODO
  String encoded_cat = serializeCategory(task.category);
  String encoded_score = task.score.toString();
  String encoded_user = "user"; // TODO
  return task.name + sep + task.description + sep + encoded_date + sep + encoded_hour + sep + encoded_cat + sep + encoded_score + sep + encoded_user;
}
