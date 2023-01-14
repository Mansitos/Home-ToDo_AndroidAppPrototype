import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:home_to_do/data_types/global_settings.dart';
import 'package:path_provider/path_provider.dart';
import 'package:home_to_do/utilities/globals.dart' as globals;

import 'generic_utilities.dart';

class GlobalSettingsStorage {
  // Getting the local documents path
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localGlobalSettingsFile async {
    final path = await _localPath;

    File file = File('$path/global_settings.txt');

    if (file.existsSync()) {
      return file;
    } else {
      debugPrint(" > Creating global_settings file because it was missing!");
      file = await File('$path/global_settings.txt').create(recursive: true);
      if (file.existsSync()) {}
    }

    return file;
  }

  Future<File> saveGlobalSettingsToFile(GlobalSettings settings) async {
    final file = await _localGlobalSettingsFile;

    String encode = settings.lastUniqueGeneratedID.toString() + "|" + encodeBool(settings.popUpMessagesEnabled) + "|" + encodeBool(settings.compactTaskListViewEnabled) + "|" + encodeBool(settings.alwaysShowExpiredTasks) + "|" + encodeBool(settings.autoMonthOldDelete);

    debugPrint("\n > Global Settings saved successfully! location/path: " + file.path);
    return file.writeAsString('$encode');
  }

  Future<void> loadGlobalSettingsFromFile() async {
    try {
      final file = await _localGlobalSettingsFile;
      final contents = await file.readAsString();

      List<String> data = contents.split('|');

      if (contents != "") {
        GlobalSettings settings = GlobalSettings(lastUniqueGeneratedID: int.parse(data[0]), popUpMessagesEnabled: decodeBool(data[1]), compactTaskListViewEnabled: decodeBool(data[2]), alwaysShowExpiredTasks: decodeBool(data[3]), autoMonthOldDelete: decodeBool(data[4]));

        globals.lastUniqueGeneratedID = settings.lastUniqueGeneratedID;
        globals.popUpMessagesEnabled = settings.popUpMessagesEnabled;
        globals.compactTaskListViewEnabled = settings.compactTaskListViewEnabled;
        globals.alwaysShowExpiredTasks = settings.alwaysShowExpiredTasks;
        globals.autoMonthOldDelete = settings.autoMonthOldDelete;
      }
      debugPrint(" > Global Settings loaded successfully!");
    } catch (e) {
      debugPrint(" > Error in loading Global Settings file!");
      debugPrint(e.toString());
    }
  }
}
