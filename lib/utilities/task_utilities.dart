import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_to_do/data_types/category.dart';
import 'package:home_to_do/data_types/task.dart';
import 'package:home_to_do/data_types/user.dart';
import 'package:home_to_do/utilities/categories_utilities.dart';
import 'package:home_to_do/utilities/users_utilities.dart';
import '../data_types/task_filter.dart';
import 'generic_utilities.dart';
import 'globals.dart' as globals;
import 'notification_api.dart';

Future<void> createNewTask(String name, String desc, Category cat, DateTime date, TimeOfDay hour, int score, User user, String repeat, bool notification) async {
  name = name.capitalize();
  desc = desc.capitalize();

  Task newTask = Task(id: globals.generateUniqueTaskID(), name: name, description: desc, category: cat, dateLimit: date, timeLimit: hour, score: score, user: user, repeat: repeat, notification: notification);

  globals.tasks.add(newTask);

  if (notification == true) {
    LocalNoticeService().addNotification(id: newTask.getID(), title: cat.emoji + " " + name, body: desc, date: DateTime(date.year, date.month, date.day, hour.hour, hour.minute), channel: 'main_channel');
  }

  debugPrint("\n > New task saved!\n" + serializeTask(newTask));
  await globals.tasksStorage.saveTasksToFile(globals.tasks);
  // Reload is needed so images are reloaded...
  await globals.tasksStorage.loadTasksFromFile();
}

Future<void> modifyTask(Task task, String name, String desc, Category cat, DateTime date, TimeOfDay hour, int score, User user, String repeat, bool notification) async {
  name = name.capitalize();
  desc = desc.capitalize();

  // Regenerate the local notification
  LocalNoticeService().cancelNotificationByID(task.getID());
  if (notification == true) {
    LocalNoticeService().addNotification(id: task.getID(), title: cat.emoji + " " + name, body: desc, date: DateTime(date.year, date.month, date.day, hour.hour, hour.minute), channel: 'main_channel');
  }

  Task modifiedTask = Task(id: task.getID(), name: name, description: desc, category: cat, dateLimit: date, timeLimit: hour, score: score, user: user, repeat: repeat, notification: notification);
  modifiedTask.setCompleted(task.getCompleted());

  if (task.repeat == repeat) {
    // repeat mode the same
    modifiedTask.setNextRepeatedTaskSpawned(task.getNextRepeatedTaskSpawned());
  } else {
    // repeat mode changed! restore clone behaviour
    modifiedTask.setNextRepeatedTaskSpawned(false);
  }
  modifiedTask.setUserThatCompleted(task.getUserThatCompleted());
  debugPrint("\n > Modify task with ID " + task.getID().toString());
  int index = getIndexOfTaskByID(task.getID()); // get list index where to overwrite...
  globals.tasks[index] = modifiedTask; // overwrite...
  debugPrint("Now tasks are: " + globals.tasks.toString());
  await globals.tasksStorage.saveTasksToFile(globals.tasks);
  // Reload is needed so images are reloaded...
  await globals.tasksStorage.loadTasksFromFile();
}

Future<void> deleteTaskByID(int id) async {
  debugPrint("\n > Delete task with ID:" + id.toString());
  int index = getIndexOfTaskByID(id);
  globals.tasks.removeAt(index);
  debugPrint("Now tasks are: " + globals.tasks.toString());
  LocalNoticeService().cancelNotificationByID(id);
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
  String repeat = data[10];
  bool nextRepeatedSpawned = decodeBool(data[11]);
  bool notification = decodeBool(data[12]);

  Task task = Task(id: id, name: name, description: desc, dateLimit: date, timeLimit: time, category: cat, score: score, user: user, repeat: repeat, notification: notification);
  task.setCompleted(completed);
  task.setNextRepeatedTaskSpawned(nextRepeatedSpawned);
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
  String encodedRepeat = task.repeat;
  String encodedNextRepeatedSpawned = encodeBool(task.getNextRepeatedTaskSpawned());
  String encodedNotification = encodeBool(task.notification);

  String encoded = encodedID + sep + encodedName + sep + encodedDesc + sep + encodedDate + sep + encodedHour + sep + encodedCat + sep + encodedScore + sep + encodedUser + sep + encodeCompleted + sep + encodedCompletedUser + sep + encodedRepeat + sep + encodedNextRepeatedSpawned + sep + encodedNotification;
  return encoded;
}

List<Task> getSelectedTasksList(TaskFilter selectionFilter) {
  List<Task> allTasks = globals.tasks;
  return selectionFilter.applyTo(allTasks, true);
}

List<Task> getExpiredTasksList(TaskFilter selectionFilter) {
  List<Task> allTasks = globals.tasks;
  TaskFilter availableExpiredTasksFilter = TaskFilter(startingDate: DateTime(0), endDate: DateTime.now().subtract(new Duration(days: 1)), category: selectionFilter.category, user: selectionFilter.user);
  return availableExpiredTasksFilter.applyTo(allTasks, true);
}
