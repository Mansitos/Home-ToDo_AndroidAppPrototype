import 'package:flutter/material.dart';
import 'package:home_to_do/data_types/task.dart';
import 'package:home_to_do/data_types/user.dart';
import 'package:home_to_do/utilities/globals.dart' as globals;

import '../utilities/generic_utilities.dart';
import 'category.dart';

class TaskFilter {
  TaskFilter({this.category, this.user, required this.startingDate, this.endDate});

  Category? category; // if null -> every category is ok
  User? user; // if null -> every user is ok
  DateTime startingDate;
  DateTime? endDate; // if null -> endDate = endless

  List<Task> applyTo(List<Task> tasksToFilter, bool sort) {
    debugPrint("\n------------ Task Filter Log ------------");
    debugPrint(" > Input tasks count: " + tasksToFilter.length.toString());
    debugPrint(" > Category: " + category.toString());
    debugPrint(" > User: " + user.toString());
    debugPrint(" > Date Interval: " + startingDate.toString() + " to " + endDate.toString());

    List<Task> filteredTasks = [];
    for (var i = 0; i <= tasksToFilter.length - 1; i++) {
      Task task = tasksToFilter[i]; // getting i-th task...

      if (category != null) { // Filter by category...
        if (task.category.toString() == category.toString() || category.toString() == globals.categories[0].toString()) {
          if (checkDateLimit(task, endDate, startingDate)) { // Filter by date/time...
            if (user!.name == globals.users[0].name || user!.name == task.user.name || task.user.name == globals.users[0].name) {
              filteredTasks.add(task);
            } else {
              continue; // Selected user was not "All" or the one assigned for this task, discard and check next task.
            }
          } else {
            continue; // Task date was not in range of filter, discard and check next task.
          }
        } else {
          continue; // Category was different, discard and check next task.
        }
      }
    }

    debugPrint(" > Filtered tasks count: " + filteredTasks.length.toString());

    if (sort == true) {
      filteredTasks = _sortByDate(filteredTasks);
      debugPrint(" > Task were also temporally ordered!");
    }

    debugPrint("-----------------------------------------");
    return filteredTasks;
  }


  List<Task> _sortByDate(List<Task> filteredTasks) {
    int taskDateComparison(Task a, Task b) {
      DateTime scoreA = a.dateLimit;
      DateTime scoreB = b.dateLimit;
      if (scoreA.isBefore(scoreB)) {
        return -1;
      } else if (scoreA.isAfter(scoreB)) {
        return 1;
      } else {
        return 0;
      }
    }

    filteredTasks.sort(taskDateComparison);
    return filteredTasks;
  }
}

