import 'package:home_to_do/data_types/category.dart';
import 'package:home_to_do/data_types/task.dart';
import 'package:home_to_do/utilities/task_storage.dart';
import '/utilities/categories_storage.dart';

final CategoriesStorage categoriesStorage = CategoriesStorage();
List<Category> categories = [];

final TasksStorage tasksStorage = TasksStorage();
List<Task> tasks = [];
int lastUniqueGeneratedID = -1;

bool debugMode = true;
