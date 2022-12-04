import 'package:flutter/material.dart';
import 'package:home_to_do/data_types/task.dart';
import 'package:home_to_do/data_types/user.dart';
import 'package:home_to_do/utilities/globals.dart' as globals;

import 'category.dart';

class TaskFilter {
  TaskFilter({this.category, this.user, required this.startingDate, this.endDate});

  Category? category; // if null -> every category is ok
  User? user; // if null -> every user is ok
  DateTime startingDate;
  DateTime? endDate; // if null -> endDate = endless

  List<Task> applyTo(List<Task> tasksToFilter) {
    debugPrint("\n------------ Task Filter Log ------------");
    debugPrint(" > Input tasks count: " + tasksToFilter.length.toString());
    debugPrint(" > Category: " + category.toString());
    debugPrint(" > User: " + user.toString());
    debugPrint(" > Date Interval: " + startingDate.toString() + " to " + endDate.toString());

    List<Task> filteredTasks = [];
    for (var i = 0; i <= tasksToFilter.length - 1; i++) {
      Task task = tasksToFilter[i]; // getting i-th task...

      if (category != null) {
        // Filter category...
        if (task.category.toString() == category.toString() || category == globals.categories[0]) {
          if (checkDateLimit(task)) {
            filteredTasks.add(task);
          } else {
            print("discarded for time date");
            continue; // Task date was not in range of filter, discad and check next task.
          }
        } else {
          continue; // Category was different, discard and check next task.
        }
      }
    }

    debugPrint(" > Filtered tasks count: " + filteredTasks.length.toString());
    debugPrint("-----------------------------------------");
    return filteredTasks;
  }

  bool checkDateLimit(Task task) {
    if (endDate == null) {
      // It's not a range check.
      return areSameDay(startingDate, task.dateLimit);
    } else if ((task.dateLimit.isBefore(endDate!) || areSameDay(task.dateLimit,endDate!)) && (startingDate.isBefore(task.dateLimit))|| areSameDay(startingDate,task.dateLimit)) {
      // It's a range check!
      return true;
    } else {
      return false;
    }
  }

  bool areSameDay(DateTime first, DateTime second) {
    return (first.year == second.year && first.month == second.month && first.day == second.day);
  }
}
