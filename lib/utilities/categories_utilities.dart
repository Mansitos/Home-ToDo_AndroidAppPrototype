import 'globals.dart' as globals;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/custom_widgets/category_form_dialog.dart';


void createNewCategory(String name, String emoji) {
  String newCategory = emoji + " " + name;
  globals.categories.add(newCategory);
  debugPrint("New category saved! " + newCategory);
  globals.categoriesStorage.saveCategoriesToFile(globals.categories);
}

Future<void> modifyCategoryProcedure(context, int index) async {
  debugPrint("Category " + index.toString() + " long pressed");
  // Spawn drop-down-list with delete or modify

  modifyCategory(index, "test", "A");
}

Future<void> modifyCategory(int index, String name, String emoji) async {
  String modified = emoji + " " + name;
  debugPrint("Modify class with index " + index.toString());
  globals.categories[index] = modified;
  debugPrint(" > Now categories are: " + globals.categories.toString());
}

Future<void> deleteCategory(int index) async {
  debugPrint("Delete class with index " + index.toString());
  globals.categories.removeAt(index);
  debugPrint(" > Now categories are: " + globals.categories.toString());
}

