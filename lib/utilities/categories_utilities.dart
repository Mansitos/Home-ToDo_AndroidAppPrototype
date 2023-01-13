import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_to_do/data_types/category.dart';
import 'package:home_to_do/data_types/task.dart';
import 'package:home_to_do/utilities/generic_utilities.dart';
import 'globals.dart' as globals;

Future<void> createNewCategory(String name, String emoji) async {
  name = name.capitalize();

  Category newCategory = Category(name: name, emoji: emoji);
  globals.categories.add(newCategory);
  debugPrint("\n > New category saved!\n" + serializeCategory(newCategory));
  await globals.categoriesStorage.saveCategoriesToFile(globals.categories);
  await globals.categoriesStorage.loadCategoriesFromFile();
}

Future<void> modifyCategory(int index, String name, String emoji) async {
  name = name.capitalize();

  Category modified = Category(name: name, emoji: emoji);
  debugPrint("\n > Modify class with index " + index.toString());
  Category oldCategory = globals.categories[index];
  globals.categories[index] = modified;
  debugPrint("Now categories are: " + globals.categories.toString());
  globals.categoriesStorage.saveCategoriesToFile(globals.categories);
  _updateTaskWithMatchingCategory(oldCategory,modified);
}

void _updateTaskWithMatchingCategory(Category oldCategory, Category newCategory) {
  List<Task> tasks = globals.tasks;
  int count = 0;
  for(int i = 0;i<=tasks.length-1;i++){
    Task task = tasks[i];
    if(task.category.toString() == oldCategory.toString()){
      count++;
      task.category = newCategory;
    }
  }
  debugPrint(" > "+count.toString()+ " tasks modified due to category modify process.");
}

Future<void> deleteCategory(int index) async {
  debugPrint("\n > Delete class with index " + index.toString());
  Category oldCategory = globals.categories[index];
  globals.categories.removeAt(index);
  debugPrint("Now categories are: " + globals.categories.toString());
  globals.categoriesStorage.saveCategoriesToFile(globals.categories);
  _updateTaskWithMatchingCategory(oldCategory,globals.categories[0]);
}

Category decodeSerializedCategory(String encode) {
  String emoji = encode.substring(0, 2);
  String name  = encode.substring(3);
  return Category(name: name, emoji: emoji);
}

String serializeCategory(Category category) {
  return category.emoji + " " + category.name;
}

bool checkIfCategoryNameAvailable(String name, String emoji, String mask, bool maskMode) {
  name = name.capitalize();

  for (var i = 0; i < globals.categories.length; i++) {
    if (maskMode == true) {
      if (name != mask && emoji != mask) {
        if (name == globals.categories[i].name || emoji == globals.categories[i].emoji) {
          debugPrint(" > Cannot create/modify category! emoji or name already used");
          return false;
        }
      }
    } else {
      if (name == globals.categories[i].name || emoji == globals.categories[i].emoji) {
        debugPrint(" > Cannot create/modify category! emoji or name already used");
        return false;
      }
    }
  }
  return true;
}
