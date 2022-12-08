import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_to_do/custom_widgets/pop_up_message.dart';
import 'package:home_to_do/utilities/users_utilities.dart';
import 'package:home_to_do/utilities/globals.dart' as globals;
import 'package:image_picker/image_picker.dart';

class UserDialogForm extends StatefulWidget {
  const UserDialogForm({Key? key, required this.modifyMode, required this.modifyIndex}) : super(key: key);

  final bool modifyMode;
  final int modifyIndex;

  @override
  State<UserDialogForm> createState() => UserDialogFormState();
}

class UserDialogFormState extends State<UserDialogForm> {
  final _formKey = GlobalKey<FormState>();

  String userName = "";
  String oldUserName = "";
  File? userImage;

  @override
  Widget build(BuildContext context) {
    String title = "Create new user";
    if (widget.modifyMode == true) {
      title = "Modify user";
      oldUserName = globals.users[widget.modifyIndex].name;
    }

    Future _pickImage({bool fromCamera: false}) async {
      try {
        if (!fromCamera) {
          final temp = await ImagePicker().pickImage(source: ImageSource.gallery);
          this.userImage = File(temp!.path);
        }
        if (fromCamera) {
          final temp = await ImagePicker().pickImage(source: ImageSource.camera);
          this.userImage = File(temp!.path);
        }
      } catch (e) {
        print('Failed to pick image: $e');
      }
    }

    void _updateImage() {
      setState(() {});
    }

    return AlertDialog(
      title: Text(title),
      content: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
        return Form(
          key: _formKey,
          child: SizedBox(
            height: 250,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MaterialButton(
                  child: Container(color: Colors.red, width: 150, height: 150, child: _displayUserImage(img: userImage, modify: widget.modifyMode)),
                  onPressed: () {
                    // Navigator.pop close the pop-up while showing the dialog.
                    // We have to wait till the animations finish, and then open the dialog.
                    WidgetsBinding.instance?.addPostFrameCallback((_) {
                      setState(() {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("🙂 Select user picture"),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    PopupMenuItem(
                                      onTap: () async {
                                        await _pickImage(fromCamera: false);
                                        _updateImage();
                                      },
                                      value: 0,
                                      child: Row(
                                        children: <Widget>[
                                          Icon(Icons.folder),
                                          Text(" Pick image from gallery"),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      onTap: () async {
                                        await _pickImage(fromCamera: true);
                                        _updateImage();
                                      },
                                      value: 1,
                                      child: Row(
                                        children: const <Widget>[
                                          Icon(Icons.camera_alt),
                                          Text(" Take a selfie"),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              );
                            }).then((_) => setState(() {}));
                      });
                    });
                  },
                ),
                TextFormField(
                  style: TextStyle(fontSize: 18),
                  maxLength: 15,
                  initialValue: (() {
                    if (widget.modifyMode == true) {
                      return oldUserName;
                    } else {
                      return '';
                    }
                  }()),
                  decoration: const InputDecoration(
                    hintText: 'What\'s your name?',
                    labelText: 'Name',
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
                    } else if (!checkIfUserNameAvailable(value, "", oldUserName, widget.modifyMode)) {
                      return 'Name already used!';
                    } else {
                      userName = value;
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
                  heroTag: "UndoUser",
                  onPressed: () {
                    setState(() {
                      debugPrint("Undo user creation/modify button pressed!");
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
                  heroTag: "ConfirmUser",
                  onPressed: () {
                    setState(() {
                      debugPrint("Confirm user creation/modify button pressed!");
                      if (_formKey.currentState!.validate()) {
                        debugPrint("Ok! Valid category form!");
                        if (widget.modifyMode == false) {
                          Navigator.of(context).pop();
                          createNewUser(userName);
                          showPopUpMessage(context, "✅ User created!", null);
                        } else {
                          Navigator.of(context).pop();
                          modifyUser(widget.modifyIndex, userName);
                          showPopUpMessage(context, "✅ User modified!", null);
                        }
                      } else {
                        debugPrint("Error! Validation failed in user creation form!");
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

  _displayUserImage({required File? img, required bool modify}) {
    if (modify == true) {
      print("modddify!");
      // diverso...
    } else {
      if (img != null) {
        return Image.file(img);
      } else {
        return Image.asset("lib/assets/user_images/default_user_img.png");
        // default img...
      }
    }
  }
}
