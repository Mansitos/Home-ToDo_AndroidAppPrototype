import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '/utilities/globals.dart' as globals;

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

  Future<File> saveCategoriesToFile(List<String> categories) async {
    final file = await _localCategoriesFile;

    String encode = "";
    if (categories.isNotEmpty) {
      for (int i = 0; i <= categories.length - 1; i++) {
        encode = encode + categories[i] + ",";
      }
      encode = encode.substring(0, encode.length - 1); // Remove last separator
    }

    // Updating globals entry
    globals.categories = categories;

    print("Categories saved succesfully! location/path: " + file.path);
    print(categories);
    return file.writeAsString('$encode');
  }

  void loadCategoriesFromFile() async {
    try {
      final file = await _localCategoriesFile;
      final contents = await file.readAsString();
      List<String> categories = contents.split(',');
      // Updating globals entry
      globals.categories = categories;
      print("Categories loaded succesfully!");
      print(categories);
    } catch (e) {
      print("Error in loading categories file");
      print(e);
    }
  }

}

