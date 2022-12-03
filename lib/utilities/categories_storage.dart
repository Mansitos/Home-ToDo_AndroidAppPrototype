import 'dart:io';
import 'package:home_to_do/data_types/category.dart';
import 'package:home_to_do/utilities/categories_utilities.dart';
import 'package:path_provider/path_provider.dart';
import '/utilities/globals.dart' as globals;
import 'package:flutter/material.dart';

// This class handle/allows categories persistency over sessions.
// The class provides file save/load mechanism for categories.

class CategoriesStorage {
// Getting the local documents path
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localCategoriesFile async {
    final path = await _localPath;
    return File('$path/categories.txt');
  }

  Future<File> saveCategoriesToFile(List<Category> categories) async {
    final file = await _localCategoriesFile;

    // Updating globals entry TODO: uselsse, remove?
    // globals.categories = categories;

    String encode = "";
    if (categories.isNotEmpty) {
      for (int i = 0; i <= categories.length - 1; i++) {
        encode += serializeCategory(categories[i]);
        encode += '|';
      }
      encode = encode.substring(0, encode.length - 1); // Remove last separator
    }

    debugPrint("\n > Categories saved successfully! location/path: " + file.path);
    debugPrint(categories.toString());
    return file.writeAsString(encode);
  }

  Future<bool> loadCategoriesFromFile() async {
    try {
      final file = await _localCategoriesFile;
      final contents = await file.readAsString();

      List<String> encodedCategories = contents.split('|');
      List<Category> categories = [];

      if (encodedCategories.length > 1) {
        for (var i = 0; i < encodedCategories.length; i++) {
          categories.add(decodeSerializedCategory(encodedCategories[i]));
        }
      }else{
        categories.add(Category(name: "All", emoji: "🏠"));
        await globals.categoriesStorage.saveCategoriesToFile(categories);
        print(" > Regenerating default category!");
      }

      // Updating globals entry
      globals.categories = categories;
      debugPrint(" > Categories loaded successfully! (" + categories.length.toString() + ")");
      debugPrint(categories.toString());
      return true;
    } catch (e) {
      debugPrint(" > Error in loading categories file!");
      debugPrint(e.toString());
      return false;
    }
  }
}
