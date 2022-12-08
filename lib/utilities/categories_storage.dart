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

    File file = File('$path/categories.txt');

    if (file.existsSync()) {
      return file;
    } else {
      debugPrint(" > Creating categories file because it was missing!");
      file = await File('$path/categories.txt').create(recursive: true);
      if (file.existsSync()) {}
    }
    return file;
  }

  Future<File> saveCategoriesToFile(List<Category> categories) async {
    final file = await _localCategoriesFile;

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
      } else {
        categories.add(Category(name: "All", emoji: "🏠"));
        print(" > Regenerating default category!");
        await globals.categoriesStorage.saveCategoriesToFile(categories);
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
