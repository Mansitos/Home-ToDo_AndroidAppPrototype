import 'package:flutter/material.dart';

class Task {
  Task({required this.name, this.description, required this.dateLimit, required this.timeLimit});

  String name;
  String? description;
  DateTime dateLimit;
  DateTime timeLimit;
  // ....
}
