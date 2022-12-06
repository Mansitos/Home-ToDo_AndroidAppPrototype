import 'package:flutter/material.dart';
import 'package:home_to_do/data_types/category.dart';
import 'package:home_to_do/data_types/global_settings.dart';
import 'package:home_to_do/data_types/user.dart';
import 'package:home_to_do/utilities/globals.dart' as globals;

class Task {
  Task({required this.id, required this.name, required this.description, required this.dateLimit, required this.timeLimit, required this.category, required this.score, required this.user});

  final int id;
  String name;
  String description;
  DateTime dateLimit;
  TimeOfDay timeLimit;
  Category category;
  int score;
  User user;

  @override
  String toString() {
    return "(TASK-ID:"+id.toString()+"|" + name + "|" + category.toString() + "|" + score.toString() + "|" + user.toString() +"| " + dateLimit.toString() + " at " + timeLimit.toString() + ")";
  }

  int getID() {
    return id;
  }
}
