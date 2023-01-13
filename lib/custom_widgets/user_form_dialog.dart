import 'dart:io';
import 'package:flutter/material.dart';
import 'package:home_to_do/custom_widgets/pop_up_message.dart';
import 'package:home_to_do/data_types/user.dart';
import 'package:home_to_do/utilities/users_utilities.dart';
import 'package:image_crop/image_crop.dart';
import 'package:image_picker/image_picker.dart';
import 'package:home_to_do/utilities/globals.dart' as globals;

class UserDialogForm extends StatefulWidget {
  const UserDialogForm({Key? key, required this.modifyMode, required this.userToModify, required this.onChange}) : super(key: key);

  final bool modifyMode;
  final User userToModify;
  final voidCallback onChange;

  @override
  State<UserDialogForm> createState() => UserDialogFormState();
}

typedef void voidCallback();

class UserDialogFormState extends State<UserDialogForm> {
  final _formKey = GlobalKey<FormState>();

  String userName = "";
  String oldUserName = "";
  int oldScore = 0;
  File? userImage;
  File? oldUserImage;

  @override
  Widget build(BuildContext context) {
    String title = "Create New User";
    if (widget.modifyMode == true) {
      title = "Modify User";
      oldUserName = widget.userToModify.name;
      oldScore = widget.userToModify.score;
      oldUserImage = widget.userToModify.image;
    }

    Future _pickImage({bool fromCamera: false}) async {
      try {
        if (!fromCamera) {
          final temp = await ImagePicker().pickImage(source: ImageSource.gallery);
          final temp_2 = await ImageCrop.sampleImage(
            file: File(temp!.path),
            preferredWidth: 512,
            preferredHeight: 512,
          );
          this.userImage = File(temp_2.path);
        }
        if (fromCamera) {
          final temp = await ImagePicker().pickImage(source: ImageSource.camera);
          final temp_2 = await ImageCrop.sampleImage(
            file: File(temp!.path),
            preferredWidth: 512,
            preferredHeight: 512,
          );
          this.userImage = File(temp_2.path);
        }
      } catch (e) {
        print('Failed to pick image: $e');
      }
    }

    void _updateImage() {
      setState(() {
      });
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
                  child: Container(padding: EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.black, shape: BoxShape.circle), child: ClipOval(child: SizedBox.fromSize(size: Size.fromRadius(60), child: _displayUserImage()))),
                  onPressed: () {
                    // Navigator.pop close the pop-up while showing the dialog.
                    // We have to wait till the animations finish, and then open the dialog.
                    WidgetsBinding.instance?.addPostFrameCallback((_) {
                      setState(() {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("📷 Select User Picture"),
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
                Container(height: 4,),
                Text("Tap to change picture!", style: TextStyle(color: Colors.black54, fontSize: 10),),
                Theme(
                  data: Theme.of(context).copyWith(
                      textSelectionTheme: TextSelectionThemeData(
                          selectionColor: Colors.amber)),
                  child: TextFormField(
                    cursorColor: Colors.amber,
                    style: TextStyle(fontSize: 18),
                    maxLength: globals.userMaxLen,
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
                      labelStyle: TextStyle(fontSize: 16, color: Colors.black45),
                      hintStyle: TextStyle(fontSize: 16, color: Colors.black45),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black45)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.amber)),

                    ),
                    onSaved: (String? value) {
                      setState(() {});
                    },
                    validator: (String? value) {
                      final validCharacters = globals.userValidChars;
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
                  onPressed: () async {
                      debugPrint("Confirm user creation/modify button pressed!");
                      if (_formKey.currentState!.validate()) {
                        debugPrint("Ok! Valid category form!");
                        if (widget.modifyMode == false) {
                          Navigator.of(context).pop();
                          await createNewUser(userName, userImage);
                          showPopUpMessage(context, "✅", "User Created!", null);
                        } else {
                          Navigator.of(context).pop();
                          await modifyUserByName(oldUserName, userName, oldScore, userImage, false);
                          showPopUpMessage(context, "✅", "User Modified!", null);
                        }
                      } else {
                        debugPrint("Error! Validation failed in user creation form!");
                      }

                    setState(() {
                      widget.onChange();
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

  _displayUserImage() {
    if(widget.modifyMode == false) {
      if (userImage != null) {
        return Image.file(userImage!, fit: BoxFit.cover,);
      } else {
        return Image.asset("lib/assets/user_images/default_user_img.png", fit: BoxFit.cover,);
      }
    }else{
      if (userImage != null) {
        return Image.file(userImage!, fit: BoxFit.cover,);
      } else if(oldUserImage != null){
        return Image.file(oldUserImage!, fit: BoxFit.cover,);
      }else{
        return Image.asset("lib/assets/user_images/default_user_img.png", fit: BoxFit.cover,);
      }

    }

  }
}
