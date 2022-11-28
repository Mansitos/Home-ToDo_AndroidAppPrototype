import 'package:home_to_do/data_types/category.dart';
import 'package:home_to_do/data_types/user.dart';
import 'package:home_to_do/utilities/globals.dart' as globals;

class Task {
  Task({required this.name, required this.description, this.dateLimit, this.timeLimit, required this.category, required this.user});

  final _id = _generateUniqueID();
  String name;
  String description;
  DateTime? dateLimit;
  DateTime? timeLimit;
  Category category;
  User user;

  @override
  String toString() {
    return "task:" + name;
  }

  static _generateUniqueID() {
    int newUniqueID = globals.lastUniqueGeneratedID += 1;
    // Updating the last used unique task ID!
    globals.lastUniqueGeneratedID = newUniqueID;
    globals.tasksStorage.saveTasksIDToFile(newUniqueID);
    return newUniqueID;
  }

  int getID() {
    return _id;
  }
}
