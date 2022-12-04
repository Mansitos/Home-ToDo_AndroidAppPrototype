import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_to_do/data_types/task.dart';
import 'package:home_to_do/pages/task_page.dart';
import 'package:home_to_do/utilities/task_utilities.dart' as tasks;
import 'package:home_to_do/utilities/globals.dart' as globals;

class TaskTileWidget extends StatefulWidget {
  const TaskTileWidget({Key? key, required this.task, required this.onChange}) : super(key: key);

  final Task task;
  final voidCallback onChange;

  @override
  State<TaskTileWidget> createState() => TaskTileWidgetState();
}

typedef void voidCallback();

class TaskTileWidgetState extends State<TaskTileWidget> {
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
          style: TextButton.styleFrom(
            primary: Colors.black,
            backgroundColor: Colors.white,
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
                      tasks.deleteTaskByID(widget.task.getID()).then((_) => setState(() {}));
                      widget.onChange();
                    },
                    value: 0,
                    child: Row(
                      children: const <Widget>[
                        Icon(Icons.delete, color: Colors.red,),
                        Text("Delete", style: TextStyle(color: Colors.red),),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    onTap: () {
                      // Navigator.pop close the pop-up while showing the dialog.
                      // We have to wait till the animations finish, and then open the dialog.
                      WidgetsBinding.instance?.addPostFrameCallback((_) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => TaskScreen(mode: "Modify", taskToModify: widget.task))).then((value) => setState(() {
                              widget.onChange();
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
                ]);
          },
          onPressed: () {},
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Checkbox(
                  value: selected,
                  onChanged: (bool? value) {
                    setState(() {});
                  }),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2, bottom: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.task.name,
                        style: const TextStyle(fontSize: 15),
                      ),
                      Text(
                        _getTaskTileDescriptionText(),
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      color: Colors.black,
                      height: 45,
                      width: 45,
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

  String _getTaskTileDescriptionText() {
    if(globals.debugMode == false){
      return widget.task.description;
    }else{
      // So variables can be seen at run-time.....
      return ">> DEBUG MODE <<\n"+ widget.task.toString();
    }

  }
}
