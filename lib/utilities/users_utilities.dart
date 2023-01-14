import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_to_do/data_types/user.dart';
import 'package:home_to_do/data_types/task.dart';
import 'package:home_to_do/utilities/generic_utilities.dart';
import 'globals.dart' as globals;

Future<void> createNewUser(String name, File? image) async {
  name = name.capitalize();

  User newUser = User(name: name, score: 0);
  globals.users.add(newUser);

  if (image != null) {
    await globals.usersStorage.saveUserImage(name, image);
    newUser.image = image;
  }
  debugPrint("\n > New User saved!\n" + serializeUser(newUser));

  await globals.usersStorage.saveUsersToFile(globals.users);
}

Future<void> modifyUserByName(String oldName, String newName, int score, File? newImage, bool updateScoreMode) async {
  newName = newName.capitalize();

  int index = getIndexOfUserByName(oldName);
  User oldUser = globals.users[index];
  String oldUserName = oldUser.name;

  oldUser.name = newName;
  oldUser.score = score;

  File? oldImage = oldUser.image;

  if (!updateScoreMode) {
    if (newImage != null) {
      // ... there is a new image
      await globals.usersStorage.saveUserImage(newName, newImage); // ... save the new one
      oldUser.image = newImage;
    } else if (oldUser.image != null && newName == oldName) {
      // ... there were an image, re-use it (name is the same!) | actually no changes
      oldUser.image = oldImage;
    } else if (oldUser.image != null && newName != oldName) {
      await globals.usersStorage.updateUserImageFilename(oldName, newName); // rename image
    }
  }

  debugPrint("\n > Modified user with index " + index.toString());
  debugPrint("Now users are: " + globals.users.toString());
  await _updateTaskWithMatchingUser(oldUserName, index);
  await globals.usersStorage.saveUsersToFile(globals.users);
}

Future<void> _updateTaskWithMatchingUser(String oldUserName, int newUserIndex) async {
  List<Task> tasks = globals.tasks;
  for (int i = 0; i <= tasks.length - 1; i++) {
    Task task = tasks[i];
    if (task.user.name == oldUserName) {
      task.user = globals.users[newUserIndex];
    }
    if (task.getUserThatCompleted() != null && task.getUserThatCompleted()!.name == oldUserName) {
      task.setUserThatCompleted(globals.users[newUserIndex]);
    }
  }
  debugPrint(" > Tasks modified due to User modify process.");
  await globals.tasksStorage.saveTasksToFile(globals.tasks);
}

Future<void> deleteUser(User user) async {

  debugPrint("\n > Delete class with name: " + user.name);
  int index = getIndexOfUserByName(user.name);
  User oldUser = globals.users[index];
  String oldUserName = oldUser.name;
  globals.users.removeAt(index);
  globals.usersStorage.deleteUserImage(oldUser.name);
  debugPrint("Now users are: " + globals.users.toString());
  _updateTaskWithMatchingUser(oldUserName, 0);
  await globals.usersStorage.saveUsersToFile(globals.users);
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
  List<String> data = encode.split('/');
  String name = data[0];
  int score = int.parse(data[1]);
  return User(name: name, score: score);
}

String serializeUser(User user) {
  return user.name + "/" + user.score.toString();
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
