import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:home_to_do/data_types/task.dart';
import 'package:home_to_do/utilities/task_utilities.dart';
import 'package:path_provider/path_provider.dart';
import '/utilities/globals.dart' as globals;

// This class handle/allows tasks persistency over sessions.
// The class provides file save/load mechanism for tasks.

class TasksStorage {
// Getting the local documents path
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localTasksFile async {
    final path = await _localPath;
    return File('$path/tasks.txt');
  }

  Future<File> saveTasksToFile(List<Task> tasks) async {
    final file = await _localTasksFile;

    // Updating globals entry TODO: useless, remove?
    // globals.tasks = tasks;

    String encode = "";
    if (tasks.isNotEmpty) {
      for (int i = 0; i <= tasks.length - 1; i++) {
        encode += serializeTask(tasks[i]);
        encode += '|';
      }
      encode = encode.substring(0, encode.length - 1); // Remove last separator
    }

    debugPrint("\n > Tasks saved successfully! location/path: " + file.path);
    debugPrint(tasks.toString());
    return file.writeAsString('$encode');
  }

  Future<bool> loadTasksFromFile() async {
    try {
      final file = await _localTasksFile;
      final contents = await file.readAsString();

      List<String> encodedTasks = contents.split('|');
      List<Task> tasks = [];

      for (var i = 0; i < encodedTasks.length; i++) {
        tasks.add(decodeSerializedTask(encodedTasks[i]));
      }

      // Updating globals entry
      globals.tasks = tasks;
      debugPrint(" > Tasks loaded successfully! (" + tasks.length.toString() + ")");
      debugPrint(tasks.toString());
      return true;
    } catch (e) {
      debugPrint(" > Error in loading tasks file!");
      debugPrint(e.toString());
      return false;
    }
  }

  Future<File> get _localTasksIDFile async {
    final path = await _localPath;
    return File('$path/tasks_ID.txt');
  }

  Future<File> saveTasksIDToFile(int id) async {
    final file = await _localTasksIDFile;
    return file.writeAsString(id.toString());
  }

  Future<bool> loadTasksIDFromFile() async {
    try {
      final file = await _localTasksIDFile;
      final id = await file.readAsString();
      globals.lastUniqueGeneratedID = int.parse(id);
      return true;
    } catch (e) {
      return false;
    }
  }
}
