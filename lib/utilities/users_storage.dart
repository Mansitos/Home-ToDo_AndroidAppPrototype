import 'dart:io';
import 'package:home_to_do/data_types/user.dart';
import 'package:home_to_do/utilities/users_utilities.dart';
import 'package:path_provider/path_provider.dart';
import '/utilities/globals.dart' as globals;
import 'package:flutter/material.dart';

// This class handle/allows Users persistency over sessions.
// The class provides file save/load mechanism for Users.

class UsersStorage {
// Getting the local documents path
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localUsersFile async {
    final path = await _localPath;

    File file = File('$path/users.txt');

    if (file.existsSync()) {
      return file;
    } else {
      debugPrint(" > Creating Users file because it was missing!");
      file = await File('$path/users.txt').create(recursive: true);
      if (file.existsSync()) {}
    }
    return file;
  }

  Future<File> saveUsersToFile(List<User> users) async {
    final file = await _localUsersFile;

    String encode = "";
    if (users.isNotEmpty) {
      for (int i = 0; i <= users.length - 1; i++) {
        encode += serializeUser(users[i]);
        encode += '|';
      }
      encode = encode.substring(0, encode.length - 1); // Remove last separator
    }

    debugPrint("\n > Users saved successfully! location/path: " + file.path);
    debugPrint(users.toString());
    return file.writeAsString(encode);
  }

  Future<bool> loadUsersFromFile() async {
    try {
      final file = await _localUsersFile;
      final contents = await file.readAsString();

      List<String> encodedUsers = contents.split('|');
      List<User> users = [];

      if (encodedUsers.length > 1) {
        for (var i = 0; i < encodedUsers.length; i++) {
          users.add(decodeSerializedUser(encodedUsers[i]));
        }
      } else {
        users.add(User(name: "All", score: 999999999999999999));
        print(" > Regenerating default User!");
        await globals.usersStorage.saveUsersToFile(users);
      }

      // Updating globals entry
      globals.users = users;
      debugPrint(" > Users loaded successfully! (" + users.length.toString() + ")");
      debugPrint(users.toString());
      return true;
    } catch (e) {
      debugPrint(" > Error in loading Users file!");
      debugPrint(e.toString());
      return false;
    }
  }
}
