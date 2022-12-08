import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_to_do/data_types/user.dart';
import 'package:home_to_do/data_types/task.dart';
import 'globals.dart' as globals;

void createNewUser(String name) {
  User newUser = User(name: name, score: 0);
  globals.users.add(newUser);
  debugPrint("\n > New User saved!\n" + serializeUser(newUser));
  globals.usersStorage.saveUsersToFile(globals.users);
}

Future<void> modifyUser(int index, String name) async {
  User modified = User(name: name, score : globals.users[index].score);
  debugPrint("\n > Modify class with index " + index.toString());
  User oldUser = globals.users[index];
  globals.users[index] = modified;
  debugPrint("Now users are: " + globals.users.toString());
  globals.usersStorage.saveUsersToFile(globals.users);
  _updateTaskWithMatchingUser(oldUser,modified);
}

void _updateTaskWithMatchingUser(User oldUser, User newUser) {
  List<Task> tasks = globals.tasks;
  int count = 0;
  for(int i = 0;i<=tasks.length-1;i++){
    Task task = tasks[i];
    if(task.user.toString() == oldUser.toString()){
      count++;
      task.user = newUser;
    }
  }
  debugPrint(" > "+count.toString()+ " tasks modified due to User modify process.");
}

Future<void> deleteUser(User user) async {
  debugPrint("\n > Delete class with name: " + user.name);
  int index = getIndexOfUserByName(user.name);
  User oldUser = globals.users[index];
  globals.users.removeAt(index);
  debugPrint("Now users are: " + globals.users.toString());
  globals.usersStorage.saveUsersToFile(globals.users);
  _updateTaskWithMatchingUser(oldUser,globals.users[0]);
}

int getIndexOfUserByName(String name) {
  for (var i = 0; i <= globals.users.length - 1; i++) {
    if (globals.users[i].name == name) {
      return i;
    }
  }
  return -1;
}

User decodeSerializedUser(String encode) {
  List<String> data = encode.split(';');
  String name  = data[0];
  int score = int.parse(data[1]);
  return User(name: name, score: score);
}

String serializeUser(User user) {
  return user.name + ";" + user.score.toString();
}

bool checkIfUserNameAvailable(String name, String emoji, String mask, bool maskMode) {
  for (var i = 0; i < globals.users.length; i++) {
    if (maskMode == true) {
      if (name != mask && emoji != mask) {
        if (name == globals.users[i].name) {
          debugPrint(" > Cannot create/modify User! name already used");
          return false;
        }
      }
    } else {
      if (name == globals.users[i].name) {
        debugPrint(" > Cannot create/modify User! name already used");
        return false;
      }
    }
  }
  return true;
}
