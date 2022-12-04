import 'package:flutter/material.dart';
import 'package:home_to_do/utilities/categories_utilities.dart';
import 'package:home_to_do/utilities/globals.dart' as globals;

class CategoryDialogForm extends StatefulWidget {
  const CategoryDialogForm({Key? key, required this.modifyMode, required this.modifyIndex}) : super(key: key);

  final bool modifyMode;
  final int modifyIndex;

  @override
  State<CategoryDialogForm> createState() => CategoryDialogFormState();
}

class CategoryDialogFormState extends State<CategoryDialogForm> {
  final _formKey = GlobalKey<FormState>();
  String categoryEmoji = "";
  String categoryName = "";

  String oldCategoryEmoji = "";
  String oldCategoryName = "";

  @override
  Widget build(BuildContext context) {
    String title = "Create new category";
    if (widget.modifyMode == true) {
      title = "Modify category";
      oldCategoryEmoji = globals.categories[widget.modifyIndex].emoji;
      oldCategoryName = globals.categories[widget.modifyIndex].name;
    }

    return AlertDialog(
      title: Text(title),
      content: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
        return Form(
          key: _formKey,
          child: SizedBox(
            height: 250,
            child: Column(
              children: [
                TextFormField(
                  style: const TextStyle(fontSize: 55),
                  initialValue: (() {
                    if (widget.modifyMode == true) {
                      return oldCategoryEmoji;
                    } else {
                      return '';
                    }
                  }()),
                  maxLength: 1,
                  decoration: const InputDecoration(
                    hintText: 'Type an emoji to use as icon!',
                    labelText: 'Category Icon',
                    labelStyle: TextStyle(fontSize: 16),
                    hintStyle: TextStyle(fontSize: 16, color: Colors.black45),
                  ),
                  onSaved: (String? value) {
                    setState(() {});
                  },
                  validator: (String? value) {
                    // Emoji valid chars
                    final RegExp REGEX_EMOJI = RegExp(r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])');
                    print("old:" + oldCategoryName);
                    print("actual:" + categoryName);

                    if (value == null || value.isEmpty) {
                      return 'Please enter an emoji!';
                    } else if (!REGEX_EMOJI.hasMatch(value)) {
                      return 'Only emoji are allowed!';
                    } else if (!checkIfAvailable("", value, oldCategoryEmoji, widget.modifyMode)) {
                      return 'Emoji already used!';
                    } else {
                      categoryEmoji = value;
                      return null;
                    }
                  },
                ),
                TextFormField(
                  style: TextStyle(fontSize: 18),
                  maxLength: 20,
                  initialValue: (() {
                    if (widget.modifyMode == true) {
                      return oldCategoryName;
                    } else {
                      return '';
                    }
                  }()),
                  decoration: const InputDecoration(
                    hintText: 'What\' the category name?',
                    labelText: 'Category name',
                    labelStyle: TextStyle(fontSize: 16),
                    hintStyle: TextStyle(fontSize: 16, color: Colors.black45),
                  ),
                  onSaved: (String? value) {
                    setState(() {});
                  },
                  validator: (String? value) {
                    final validCharacters = RegExp(r'^[a-zA-Z0-9]+$');
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text!';
                    } else if (!validCharacters.hasMatch(value)) {
                      return 'Invalid characters!';
                    } else if (!checkIfAvailable(value, "", oldCategoryName, widget.modifyMode)) {
                      return 'Name already used!';
                    } else {
                      categoryName = value;
                      return null;
                    }
                  },
                ),
              ],
            ),
          ),
        );
      }),
      actions: [
        Padding(
          padding: const EdgeInsets.all(2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: FloatingActionButton(
                  backgroundColor: Colors.redAccent,
                  heroTag: "UndoCategory",
                  onPressed: () {
                    setState(() {
                      debugPrint("Undo category creation/modify button pressed!");
                      Navigator.of(context).pop();
                    });
                  },
                  tooltip: "Cancel",
                  child: const Icon(
                    Icons.cancel,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: FloatingActionButton(
                  heroTag: "ConfirmCategory",
                  onPressed: () {
                    setState(() {
                      debugPrint("Confirm category creation/modify button pressed!");
                      if (_formKey.currentState!.validate()) {
                        debugPrint("Ok! Valid category form!");
                        if (widget.modifyMode == false) {
                          createNewCategory(categoryName, categoryEmoji);
                        } else {
                          modifyCategory(widget.modifyIndex, categoryName, categoryEmoji);
                        }
                        Navigator.of(context).pop();
                      } else {
                        debugPrint("Error! Validation failed in category creation form!");
                      }
                    });
                  },
                  tooltip: "Confirm",
                  child: const Icon(Icons.check),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
