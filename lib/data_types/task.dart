import 'package:flutter/material.dart';
import 'package:home_to_do/data_types/category.dart';
import 'package:home_to_do/data_types/user.dart';
import 'package:home_to_do/utilities/globals.dart' as globals;
import 'package:home_to_do/utilities/task_utilities.dart' as tasks;

class Task {
  Task({required this.id, required this.name, required this.description, required this.dateLimit, required this.timeLimit, required this.category, required this.score, required this.user, required this.repeat, required this.notification});

  final int id; //TODO: final....?
  String name;
  String description;
  DateTime dateLimit;
  TimeOfDay timeLimit;
  Category category;
  int score;
  User user;
  String repeat;
  bool notification;

  bool _nextRepeatedTaskAlreadySpawned = false;

  bool _completed = false;
  User? _userThatCompleted;

  @override
  String toString() {
    return "(TASK-ID:" + id.toString() + "|" + name + "|" + category.toString() + "|" + score.toString() + "|" + user.toString() + "| " + dateLimit.toString() + " at " + timeLimit.toString() + "| completed:" + _completed.toString() + " by " + _userThatCompleted.toString() + " | " + repeat + ")";
  }

  int getID() {
    return id;
  }

  bool getNextRepeatedTaskSpawned() {
    return _nextRepeatedTaskAlreadySpawned;
  }

  bool getCompleted() {
    return _completed;
  }

  void setCompleted(bool val) {
    _completed = val;
  }

  User? getUserThatCompleted() {
    return _userThatCompleted;
  }

  void setUserThatCompleted(User? user) {
    _userThatCompleted = user;
  }

  int getDayRepeatDelta(String repeat) {
    switch (repeat) {
      case "No":
        return 0;
      case "Every Day":
        return 1;
      case "Every Week":
        return 7;
      case "Every Month":
        return 30;
      default:
        return int.parse(repeat);
    }
  }

  Future<void> completeTask(User selectedUser) async {
    // Updating user that completed the task
    if (selectedUser.toString() != globals.users[0].toString()) {
      await selectedUser.addScore(score);
      _userThatCompleted = selectedUser;

      // Updating/Saving task changes
      _completed = true;
      await tasks.modifyTask(this, name, description, category, dateLimit, timeLimit, score, user, repeat, notification);
    } else {
      await user.addScore(score);
      _userThatCompleted = user;

      // Updating/Saving task changes
      _completed = true;
      await tasks.modifyTask(this, name, description, category, dateLimit, timeLimit, score, user, repeat, notification);
    }

    if (repeat != "No" && _nextRepeatedTaskAlreadySpawned == false) {
      // Spawn next repeated task procedure!
      _nextRepeatedTaskAlreadySpawned = true;
      DateTime newDateTime = dateLimit.add(Duration(days: getDayRepeatDelta(repeat)));
      await tasks.createNewTask(name, description, category, newDateTime, timeLimit, score, user, repeat, notification);

      // Update/Save this tasks changes
      await tasks.modifyTask(this, name, description, category, dateLimit, timeLimit, score, user, repeat, notification);
    }

    debugPrint(" > Task ID:" + id.toString() + " completed by " + _userThatCompleted!.name + " +" + score.toString() + "⭐");
  }

  Future<void> undoComplete() async {
    if (_userThatCompleted!.name != globals.users[0].name) {
      await _userThatCompleted!.removeScore(score);
      debugPrint(" > Task complete status reverted... " + _userThatCompleted!.name + " lost " + score.toString() + "⭐");
    }
    // Updating/Saving changes to the task
    _userThatCompleted = null;
    _completed = false;

    await tasks.modifyTask(this, name, description, category, dateLimit, timeLimit, score, user, repeat, notification);

  }

  void setNextRepeatedTaskSpawned(bool val) {
    _nextRepeatedTaskAlreadySpawned = val;
  }
}
