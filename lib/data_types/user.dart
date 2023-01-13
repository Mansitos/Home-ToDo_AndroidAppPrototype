import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:home_to_do/utilities/users_utilities.dart' as users;

class User {
  User({required this.name, required this.score});

  String name;
  File? image;
  int score;


  @override
  String toString() {
    bool hasImage = (image != null);
    return name+"("+score.toString()+"⭐)"+"hasImage:"+hasImage.toString();
  }

  Future<void> addScore(int add) async {
    debugPrint(" > User " + name + " received " + add.toString() + "⭐");
    int newScore = score+add;
    await users.modifyUserByName(name, name, newScore, image, true);
  }

  Future<void> removeScore(int remove) async {
    int newScore = score - remove;
    if(newScore < 0){
      newScore = 0;
    }
    score = newScore;
    debugPrint(" > User " + name + " lost " + remove.toString() + "⭐");
    await users.modifyUserByName(name, name, newScore, image, true);
  }
}
