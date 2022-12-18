import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_to_do/custom_widgets/pop_up_message.dart';
import 'package:home_to_do/data_types/task.dart';
import 'package:home_to_do/pages/task_page.dart';
import 'package:home_to_do/utilities/task_utilities.dart' as tasks;
import 'package:home_to_do/utilities/globals.dart' as globals;

class TaskTileWidget extends StatefulWidget {
  const TaskTileWidget({Key? key, required this.task, required this.onChange, required this.onTaskComplete}) : super(key: key);

  final Task task;
  final voidCallback onChange;
  final taskCallback onTaskComplete;

  @override
  State<TaskTileWidget> createState() => TaskTileWidgetState();
}

typedef void voidCallback();
typedef void taskCallback(Task val);

class TaskTileWidgetState extends State<TaskTileWidget> {
  var selected = false;
  late Offset _tapDownPosition;

  @override
  Widget build(BuildContext context) {
    selected = widget.task.getCompleted();

    return Padding(
      padding: globals.compactTaskListViewEnabled == false ? const EdgeInsets.only(left: 6, right: 6, top: 3, bottom: 3) : const EdgeInsets.only(left: 5, right: 5, top: 2, bottom: 2),
      child: GestureDetector(
        onTapDown: (TapDownDetails details) {
          setState(() {
            _tapDownPosition = details.globalPosition;
          });
        },
        child: TextButton(
          style: TextButton.styleFrom(
            primary: Colors.black,
            backgroundColor: selected == false ? Colors.white : Colors.white,
            padding: globals.compactTaskListViewEnabled == false ? EdgeInsets.all(6) : EdgeInsets.all(1),
          ),
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
                                title: Text("🔥 Confirm task delete?"),
                                content: Text("You can't undo this operation!"),
                                actions: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        FloatingActionButton(
                                          heroTag: "UndoTaskDelete",
                                          onPressed: () {
                                            setState(() {
                                              debugPrint("Task delete cancelled!");
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
                                            debugPrint("Task Delete confirmed!");
                                            tasks.deleteTaskByID(widget.task.getID()).then((_) => setState(() {}));
                                            widget.onChange();
                                            Navigator.of(context).pop();
                                            List<String> message = _getTaskDeleteMessage();
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
                  widget.task.getCompleted() == false
                      ? PopupMenuItem(
                          onTap: () {
                            // Navigator.pop close the pop-up while showing the dialog.
                            // We have to wait till the animations finish, and then open the dialog.
                            WidgetsBinding.instance?.addPostFrameCallback((_) {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => TaskScreen(mode: "Modify", taskToModify: widget.task))).then((value) => setState(() {
                                    widget.onChange(); // TODO: does not update :(
                                  }));
                            });
                          },
                          value: 1,
                          child: Row(
                            children: const <Widget>[
                              Icon(Icons.edit),
                              Text("Modify"),
                            ],
                          ),
                        )
                      : PopupMenuItem(
                          child: Row(
                            children: const <Widget>[
                              Icon(Icons.loop),
                              Text("Un-check"),
                            ],
                          ),
                          onTap: () {
                            // Navigator.pop close the pop-up while showing the dialog.
                            // We have to wait till the animations finish, and then open the dialog.
                            WidgetsBinding.instance?.addPostFrameCallback((_) {
                              setState(() {
                                selected = !selected;
                                widget.onTaskComplete(widget.task);
                              });
                            });
                          },
                        ),
                ]);
          },
          onPressed: () {},
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(right: 5),
                child: Transform.scale(
                  scale: 1.55,
                  child: Checkbox(
                      shape: CircleBorder(),
                      checkColor: Colors.black,
                      activeColor: Colors.amber,
                      value: selected,
                      onChanged: (bool? value) {
                        setState(() {
                          selected = !selected;
                          widget.onTaskComplete(widget.task);
                        });
                      }),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: selected == true ? EdgeInsets.only(top: 0, bottom: 0) : EdgeInsets.only(top: 2, bottom: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.task.category.emoji + " " + widget.task.name,
                        style: selected == true ? TextStyle(fontSize: 17, decoration: TextDecoration.lineThrough, color: Colors.black54) : TextStyle(fontSize: 17),
                      ),
                      Container(
                        height: 5,
                      ),
                      Text(
                        _hourToString(widget.task.timeLimit) + " - " + widget.task.dateLimit.day.toString() + "/" + widget.task.dateLimit.month.toString() + "/" + widget.task.dateLimit.year.toString(),
                        style: selected == true ? TextStyle(fontSize: 12, decoration: TextDecoration.lineThrough, color: Colors.black54) : TextStyle(fontSize: 12),
                      ),
                      Container(
                        height: 3,
                      ),
                      _getTaskTileDescriptionTextWidget()
                    ],
                  ),
                ),
              ),
              Padding(
                padding: globals.compactTaskListViewEnabled == false ? const EdgeInsets.only(top: 2, bottom: 2, left: 12, right: 10) : const EdgeInsets.only(top: 2, bottom: 2, left: 5, right: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                        child: ClipOval(
                          child: SizedBox.fromSize(
                            size: Size.fromRadius(18),
                            child: widget.task.user.image == null
                                ? Image.asset(
                                    "lib/assets/user_images/default_users_img.png",
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    widget.task.user.image!,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        )),
                    Container(
                      height: 2,
                    ),
                    Text(
                      _generateScoreWidgetText(),
                      style: TextStyle(fontSize: 8),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _getTaskTileDescriptionTextWidget() {
    if (globals.debugMode == false) {
      if (widget.task.description != "") {
        return Text(
          widget.task.description,
          style: selected == true ? TextStyle(fontSize: 10, decoration: TextDecoration.lineThrough, color: Colors.black54) : TextStyle(fontSize: 11),
        );
      } else {
        return Container();
      }
    } else {
      // So variables can be seen at run-time.....
      return Text(
        ">> DEBUG MODE <<\n" + widget.task.toString(),
        style: selected == true ? TextStyle(fontSize: 10, decoration: TextDecoration.lineThrough, color: Colors.black54) : TextStyle(fontSize: 11),
      );
    }
  }

  String _hourToString(TimeOfDay selectedHour) {
    if (selectedHour.minute >= 10) {
      return selectedHour.hour.toString() + ":" + selectedHour.minute.toString();
    } else {
      return selectedHour.hour.toString() + ":0" + selectedHour.minute.toString();
    }
  }

  List<String> _getTaskDeleteMessage() {
    List<String> deletionEmojis = ["💣", "🔥", "☠", "👍", "🧨", "💥", "❌", "☢", "☣"];
    List<String> defaultDeleteMessage = [deletionEmojis[Random().nextInt(deletionEmojis.length)], "Task deleted!"];
    bool useDefaultMessage = Random().nextBool();
    List<List<String>> deletionMessages = [
      ["🔥", "Task burnt!"],
      ["☢", "Task sent into nuclear reactor!"],
      ["😺", "Task eaten by developers cat!"],
      ["🐶", "Task eaten by a dog!"],
      ["🚀", "Task sent into space!"]
    ];

    if (useDefaultMessage) {
      return defaultDeleteMessage;
    } else {
      return deletionMessages[Random().nextInt(deletionMessages.length)];
    }
  }

  String _generateScoreWidgetText() {
    String text = "";
    for (var i = 0; i < widget.task.score; i++) {
      text += "⭐";
    }
    return text;
  }
}
