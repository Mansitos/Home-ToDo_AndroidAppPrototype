import 'package:flutter/material.dart';
import 'package:home_to_do/data_types/category.dart';
import 'package:home_to_do/data_types/global_settings.dart';
import 'package:home_to_do/data_types/task.dart';
import 'package:home_to_do/data_types/user.dart';
import 'package:home_to_do/utilities/global_settings_storage.dart';
import 'package:home_to_do/utilities/task_storage.dart';
import 'package:home_to_do/utilities/users_storage.dart';
import '/utilities/categories_storage.dart';

// Categories global variables
final CategoriesStorage categoriesStorage = CategoriesStorage();
List<Category> categories = [];

// Tasks global variables
final TasksStorage tasksStorage = TasksStorage();
List<Task> tasks = [];
int lastUniqueGeneratedID = 0;

// Users global variables
final UsersStorage usersStorage = UsersStorage();
List<User> users = [];

// Global settings global variables
final GlobalSettingsStorage globalSettingsStorage = GlobalSettingsStorage();
bool popUpMessagesEnabled = true;
bool compactTaskListViewEnabled = false;
bool alwaysShowExpiredTasks = true;
bool autoMonthOldDelete = true;

// Active viewMode
String activeViewMode = "list"; // default

// Development global variables
bool debugMode = false;

// Internal variables

RegExp taskNameValidChars = RegExp(r"^[a-zA-Z0-9,é;.çéàùè&!?@']+$");
int taskNameMaxLen = 50;
RegExp taskDescValidChars = RegExp(r"^[a-zA-Z0-9,é;.çéàùè&!?@']+$");
int taskDescMaxLen = 200;
RegExp userValidChars = RegExp(r"^[a-zA-Z0-9]+$");
int userMaxLen = 15;

generateUniqueTaskID() {
  // Updating the last used unique task ID!
  lastUniqueGeneratedID = lastUniqueGeneratedID += 1;
  globalSettingsStorage.saveGlobalSettingsToFile(GlobalSettings(lastUniqueGeneratedID: lastUniqueGeneratedID, popUpMessagesEnabled: popUpMessagesEnabled, compactTaskListViewEnabled: compactTaskListViewEnabled, alwaysShowExpiredTasks: alwaysShowExpiredTasks, autoMonthOldDelete: autoMonthOldDelete));
  return lastUniqueGeneratedID;
}