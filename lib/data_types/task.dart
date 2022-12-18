import 'package:flutter/material.dart';
import 'package:home_to_do/data_types/category.dart';
import 'package:home_to_do/data_types/user.dart';
import 'package:home_to_do/utilities/globals.dart' as globals;
import 'package:home_to_do/utilities/users_utilities.dart' as users;
import 'package:home_to_do/utilities/task_utilities.dart' as tasks;

class Task {
  Task({required this.id, required this.name, required this.description, required this.dateLimit, required this.timeLimit, required this.category, required this.score, required this.user});

  final int id; //TODO: final....?
  String name;
  String description;
  DateTime dateLimit;
  TimeOfDay timeLimit;
  Category category;
  int score;
  User user;

  bool _completed = false;
  User? _userThatCompleted;

  @override
  String toString() {
    return "(TASK-ID:"+id.toString()+"|" + name + "|" + category.toString() + "|" + score.toString() + "|" + user.toString() +"| " + dateLimit.toString() + " at " + timeLimit.toString() + "| completed:" + _completed.toString() + " by " + _userThatCompleted.toString() +")";
  }

  int getID() {
    return id;
  }

  bool getCompleted(){
    return _completed;
  }

  void setCompleted(bool val){
    _completed = val;
  }

  User? getUserThatCompleted(){
    return _userThatCompleted;
  }

  void setUserThatCompleted(User? user){
    _userThatCompleted = user;
  }

  void completeTask(User selectedUser){
    // Updating user that completed the task
    if(selectedUser.toString() != globals.users[0].toString()) {
      selectedUser.addScore(score);
      _userThatCompleted = selectedUser;

      // Updating/Saving task changes
      _completed = true;
      tasks.modifyTask(this, name, description, category, dateLimit, timeLimit, score, user);

    }else{
      user.addScore(score);
      _userThatCompleted = user;

      // Updating/Saving task changes
      _completed = true;
      tasks.modifyTask(this, name, description, category, dateLimit, timeLimit, score, user);
    }
    debugPrint(" > Task ID:" + id.toString() + " completed by " + _userThatCompleted!.name + " +" + score.toString() + "⭐");
  }

  void undoComplete(){
    if(_userThatCompleted!.name != globals.users[0].name) {
      _userThatCompleted!.removeScore(score);
      debugPrint(" > Task complete status reverted... " + _userThatCompleted!.name + " lost " + score.toString() + "⭐");
    }
    // Updating/Saving changes to the task
    _userThatCompleted = null;
    _completed = false;

    tasks.modifyTask(this, name, description, category, dateLimit, timeLimit, score, user);
  }
}
