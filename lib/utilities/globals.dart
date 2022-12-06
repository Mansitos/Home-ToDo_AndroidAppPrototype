import 'package:home_to_do/data_types/category.dart';
import 'package:home_to_do/data_types/global_settings.dart';
import 'package:home_to_do/data_types/task.dart';
import 'package:home_to_do/utilities/global_settings_storage.dart';
import 'package:home_to_do/utilities/task_storage.dart';
import '/utilities/categories_storage.dart';

// Categories global variables
final CategoriesStorage categoriesStorage = CategoriesStorage();
List<Category> categories = [];

// Tasks global variables
final TasksStorage tasksStorage = TasksStorage();
List<Task> tasks = [];
int lastUniqueGeneratedID = 0;

// Global settings global variables
final GlobalSettingsStorage globalSettingsStorage = GlobalSettingsStorage();
bool popUpMessagesEnabled = true;

// Development global variables
bool debugMode = true;

generateUniqueTaskID() {
  // Updating the last used unique task ID!
  lastUniqueGeneratedID = lastUniqueGeneratedID += 1;
  globalSettingsStorage.saveGlobalSettingsToFile(GlobalSettings(lastUniqueGeneratedID: lastUniqueGeneratedID, popUpMessagesEnabled: popUpMessagesEnabled));
  return lastUniqueGeneratedID;
}