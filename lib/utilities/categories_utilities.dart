import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_to_do/data_types/category.dart';

import 'globals.dart' as globals;

void createNewCategory(String name, String emoji) {
  Category newCategory = Category(name: name, emoji: emoji);
  globals.categories.add(newCategory);
  debugPrint("\n > New category saved!\n" + serializeCategory(newCategory));
  globals.categoriesStorage.saveCategoriesToFile(globals.categories);
}

Future<void> modifyCategory(int index, String name, String emoji) async {
  Category modified = Category(name: name, emoji: emoji);
  debugPrint("\n > Modify class with index " + index.toString());
  globals.categories[index] = modified;
  debugPrint("Now categories are: " + globals.categories.toString());
  globals.categoriesStorage.saveCategoriesToFile(globals.categories);
}

Future<void> deleteCategory(int index) async {
  debugPrint("\n > Delete class with index " + index.toString());
  globals.categories.removeAt(index);
  debugPrint("Now categories are: " + globals.categories.toString());
  globals.categoriesStorage.saveCategoriesToFile(globals.categories);
}

Category decodeSerializedCategory(String encode) {
  String emoji = encode.substring(0, 2);
  String name  = encode.substring(3);
  return Category(name: name, emoji: emoji);
}

String serializeCategory(Category category) {
  return category.emoji + " " + category.name;
}

bool checkIfAvailable(String name, String emoji, String mask, bool maskMode) {
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
