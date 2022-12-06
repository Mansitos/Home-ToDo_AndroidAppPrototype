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

    File file = File('$path/tasks.txt');

    if (file.existsSync()) {
      return file;
    } else {
      debugPrint(" > Creating tasks file because it was missing!");
      file = await File('$path/tasks.txt').create(recursive: true);
      if (file.existsSync()) {}
    }

    return file;
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

      if(contents != "") {
        for (var i = 0; i < encodedTasks.length; i++) {
          tasks.add(decodeSerializedTask(encodedTasks[i]));
        }
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
}
