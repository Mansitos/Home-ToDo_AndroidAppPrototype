import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_to_do/custom_widgets/pop_up_message.dart';
import 'package:home_to_do/custom_widgets/user_form_dialog.dart';
import 'package:home_to_do/data_types/user.dart';
import 'package:home_to_do/utilities/users_utilities.dart' as users;

// User Tile-List widget

class UserTileWidget extends StatefulWidget {
  const UserTileWidget({Key? key, required this.user, required this.onChange}) : super(key: key);

  final User user;
  final voidCallback onChange;

  @override
  State<UserTileWidget> createState() => UserTileWidgetState();
}

typedef void voidCallback();

class UserTileWidgetState extends State<UserTileWidget> {
  var selected = false;
  late Offset _tapDownPosition;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, right: 6, top: 3, bottom: 3),
      child: GestureDetector(
        onTapDown: (TapDownDetails details) {
          setState(() {
            _tapDownPosition = details.globalPosition;
          });
        },
        child: TextButton(
          style: TextButton.styleFrom(primary: Colors.white, textStyle: TextStyle(fontSize: 20)),
          onLongPress: () {
            showMenu(
                context: context,
                position: RelativeRect.fromLTRB(
                  _tapDownPosition.dx,
                  _tapDownPosition.dy,
                  _tapDownPosition.dx,
                  _tapDownPosition.dy,
                ),
                items: <PopupMenuEntry>[
                  PopupMenuItem(
                    onTap: () {
                      // Navigator.pop close the pop-up while showing the dialog.
                      // We have to wait till the animations finish, and then open the dialog.
                      WidgetsBinding.instance?.addPostFrameCallback((_) {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("🔥 Confirm user delete?"),
                                content: const Text("Tasks from this user will be moved to default user \"🙂 All\".\nYou can't undo this operation"),
                                actions: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        FloatingActionButton(
                                          heroTag: "UndoUserDelete",
                                          onPressed: () {
                                            setState(() {
                                              debugPrint("User delete cancelled!");
                                              Navigator.of(context).pop();
                                            });
                                          },
                                          tooltip: "Cancel",
                                          child: const Icon(Icons.cancel),
                                        ),
                                        FloatingActionButton(
                                          heroTag: "ConfirmDelete",
                                          backgroundColor: Colors.redAccent,
                                          onPressed: () {
                                            debugPrint("User Delete confirmed!");
                                            users.deleteUser(widget.user).then((_) => setState(() {}));
                                            widget.onChange();
                                            Navigator.of(context).pop();
                                            List<String> message = _getUserDeleteMessage();
                                            showPopUpMessage(context, message[0], message[1], null);
                                          },
                                          tooltip: "Confirm",
                                          child: const Icon(Icons.delete),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            });
                      });
                    },
                    value: 0,
                    child: Row(
                      children: const <Widget>[
                        Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        Text(
                          "Delete",
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    onTap: () {
                      // Navigator.pop close the pop-up while showing the dialog.
                      // We have to wait till the animations finish, and then open the dialog.
                      WidgetsBinding.instance?.addPostFrameCallback((_) {
                        setState(() {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return UserDialogForm(
                                  modifyMode: true,
                                  userToModify: widget.user,
                                  onChange: () {
                                    setState(() {
                                      widget.onChange();
                                    });
                                  },
                                );
                              }).then((_) => setState(() {}));
                        });
                      });
                    },
                    value: 1,
                    child: Row(
                      children: const <Widget>[
                        Icon(Icons.edit),
                        Text("Modify"),
                      ],
                    ),
                  ),
                ]);
          },
          onPressed: () {},
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2, bottom: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: ClipOval(
                            child: SizedBox.fromSize(
                              size: const Size.fromRadius(18),
                              child: widget.user.image == null
                                  ? Image.asset(
                                      "lib/assets/user_images/default_user_img.png",
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      widget.user.image!,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          )),
                      Text(
                        widget.user.name,
                      ),
                      Text(widget.user.score.toString() + " ⭐"),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _getUserDeleteMessage() {
    List<String> deletionEmojis = ["❌"];
    List<String> defaultDeleteMessage = [deletionEmojis[Random().nextInt(deletionEmojis.length)], " User Deleted!"];
    bool useDefaultMessage = Random().nextBool();
    List<List<String>> deletionMessages = [
      ["👽", "User kidnapped by aliens!"],
      ["👽", "User disappeared!"],
      ["👻", "User disappeared!"],
      ["🦁", "User eaten by developers lion!"],
      ["🚀", "User sent on a space mission!"]
    ];
    if (useDefaultMessage) {
      return defaultDeleteMessage;
    } else {
      return deletionMessages[Random().nextInt(deletionMessages.length)];
    }
  }
}
