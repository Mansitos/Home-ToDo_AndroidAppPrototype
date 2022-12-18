import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_to_do/data_types/category.dart';
import 'package:home_to_do/data_types/task.dart';
import 'package:home_to_do/data_types/user.dart';
import 'package:home_to_do/utilities/categories_utilities.dart';
import 'package:home_to_do/utilities/global_settings_storage.dart';
import 'package:home_to_do/utilities/users_utilities.dart';
import 'globals.dart' as globals;

Future<void> createNewTask(String name, String desc, Category cat, DateTime date, TimeOfDay hour, int score, User user) async {
  Task newTask = Task(id: globals.generateUniqueTaskID(), name: name, description: desc, category: cat, dateLimit: date, timeLimit: hour, score: score, user: user);

  globals.tasks.add(newTask);
  debugPrint("\n > New task saved!\n" + serializeTask(newTask));
  await globals.tasksStorage.saveTasksToFile(globals.tasks);
}

Future<void> modifyTask(Task task, String name, String desc, Category cat, DateTime date, TimeOfDay hour, int score, User user) async {
  Task modifiedTask = Task(id: task.getID(),name: name, description: desc, category: cat, dateLimit: date, timeLimit: hour, score: score, user: user);
  modifiedTask.setCompleted(task.getCompleted());
  modifiedTask.setUserThatCompleted(task.getUserThatCompleted());
  debugPrint("\n > Modify task with ID " + task.getID().toString());
  int index = getIndexOfTaskByID(task.getID()); // get list index where to overwrite...
  globals.tasks[index] = modifiedTask; // overwrite...
  debugPrint("Now tasks are: " + globals.tasks.toString());
  await globals.tasksStorage.saveTasksToFile(globals.tasks);
}

Future<void> deleteTaskByID(int id) async {
  debugPrint("\n > Delete task with ID:" + id.toString());
  int index = getIndexOfTaskByID(id);
  globals.tasks.removeAt(index);
  debugPrint("Now tasks are: " + globals.tasks.toString());
  await globals.tasksStorage.saveTasksToFile(globals.tasks);
}

int getIndexOfTaskByID(int id) {
  for (var i = 0; i <= globals.tasks.length - 1; i++) {
    if (globals.tasks[i].getID() == id) {
      return i;
    }
  }
  return -1;
}

Future<Task> decodeSerializedTask(String encode) async {
  List<String> data = encode.split(';');
  int id = int.parse(data[0]);
  String name = data[1];
  String desc = data[2];
  DateTime date = decodeDate(data[3]);
  TimeOfDay time = decodeTime(data[4]);
  Category cat = decodeSerializedCategory(data[5]);
  int score = int.parse(data[6]);
  User user = decodeSerializedUser(data[7]);
  user.image = await globals.usersStorage.loadUserImage(user.name);
  bool completed = decodeBool(data[8]);
  User? userThatCompleted = data[9] == "null" ? null : decodeSerializedUser(data[9]);
  Task task = Task(id:id,name: name, description: desc, dateLimit: date, timeLimit: time, category: cat, score: score, user: user);
  task.setCompleted(completed);
  task.setUserThatCompleted(userThatCompleted);
  return task;
}

String serializeTask(Task task) {
  String sep = ';';
  String encodedID = task.getID().toString();
  String encodedName = task.name;
  String encodedDesc = task.description;
  String encodedDate = encodeDate(task.dateLimit);
  String encodedHour = encodeTime(task.timeLimit);
  String encodedCat = serializeCategory(task.category);
  String encodedScore = task.score.toString();
  String encodedUser = serializeUser(task.user);
  String encodeCompleted = encodeBool(task.getCompleted());
  String encodedCompletedUser = task.getUserThatCompleted() == null ? "null" : serializeUser(task.getUserThatCompleted()!);
  String encoded = encodedID + sep + encodedName + sep + encodedDesc + sep + encodedDate + sep + encodedHour + sep + encodedCat + sep + encodedScore + sep + encodedUser + sep + encodeCompleted + sep + encodedCompletedUser;
  return encoded;
}

String encodeDate(DateTime date) {
  return date.toString();
}

String encodeTime(TimeOfDay time) {
  String encode = time.hour.toString() + "-" + time.minute.toString();
  return encode;
}

DateTime decodeDate(String encode) {
  DateTime date = DateTime.parse(encode);
  return date;
}

TimeOfDay decodeTime(String encode) {
  List<String> data = encode.split('-');
  return TimeOfDay(hour: int.parse(data[0]), minute: int.parse(data[1]));
}
