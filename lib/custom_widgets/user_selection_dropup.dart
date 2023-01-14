import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_to_do/data_types/user.dart';
import 'package:home_to_do/utilities/globals.dart' as globals;

// Main-Screen User selection drop-up widget

class UserSelectionDropUpWidget extends StatefulWidget {
  UserSelectionDropUpWidget({Key? key, required this.onUserSelected, required this.actuallySelectedUser}) : super(key: key);

  final userSelectedCallback onUserSelected;
  User actuallySelectedUser;

  @override
  State<UserSelectionDropUpWidget> createState() => UserSelectionDropUpWidgetState();
}

typedef void userSelectedCallback(User user);

class UserSelectionDropUpWidgetState extends State<UserSelectionDropUpWidget> {
  bool isVisible = false;

  MediaQueryData? queryData;
  double screenWidth = 0;
  double screenHeight = 0;

  changeIsVisible() => {isVisible = !isVisible};

  void userSelected(User user) {
    setState(() {
      widget.onUserSelected(user);
      changeIsVisible();
    });
  }

  @override
  Widget build(BuildContext context) {
    queryData = MediaQuery.of(context);
    screenWidth = queryData!.size.width;
    screenHeight = queryData!.size.height;

    return Visibility(
      visible: isVisible,
      child: Align(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(screenWidth * 0.0425),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                spreadRadius: 0.05,
                blurRadius: 6,
                offset: const Offset(0, 0), // changes position of shadow
              ),
            ],
          ),
          height: screenHeight * 0.305,
          width: screenWidth * 0.175,
          child: Card(
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.black87, width: 1.5),
              borderRadius: BorderRadius.circular(screenWidth * 0.0425),
            ),
            child: Padding(
              padding: EdgeInsets.only(left: screenWidth * 0.01, right: screenWidth * 0.01, top: screenWidth * 0.0025, bottom: screenWidth * 0.0025),
              child: Container(
                child: ListView(
                  shrinkWrap: true,
                  children: _userSelectorsBuilder(context, userSelected),
                ),
              ),
            ),
          ),
        ),
        alignment: const FractionalOffset(0.25 / 4, 1),
      ),
    );
  }

  List<Widget> _userSelectorsBuilder(BuildContext context, void Function(User user) userSelected) {
    List<Widget> userSelectors = [];

    for (int i = 0; i < globals.users.length; i++) {
      User current_user = globals.users[i];
      bool is_selected = current_user.name == widget.actuallySelectedUser.name;

      Widget selector = Padding(
          padding: EdgeInsets.all(screenWidth * 0.01),
          child: Column(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                icon: Container(
                    padding: is_selected ? const EdgeInsets.all(4) : const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: is_selected ? Colors.amber : Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: SizedBox.fromSize(
                        size: Size.fromRadius(screenWidth * 0.05),
                        child: _getUserImage(current_user),
                      ),
                    )),
                onPressed: () {
                  userSelected(current_user);
                },
                style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    minimumSize: Size.fromRadius(
                      screenWidth * 0.065,
                    )),
              ),
              Container(
                height: 1,
              ),
              Text(
                current_user.name,
                style: is_selected ? const TextStyle(fontSize: 13) : const TextStyle(fontSize: 12),
              )
            ],
          ));
      userSelectors.add(selector);
    }

    return userSelectors;
  }

  _getUserImage(User current_user) {
    if (current_user.name == globals.users[0].name) {
      return Image.asset(
        "lib/assets/user_images/default_users_img.png",
        fit: BoxFit.cover,
      );
    }
    if (current_user.image == null) {
      return Image.asset(
        "lib/assets/user_images/default_user_img.png",
        fit: BoxFit.cover,
      );
    } else {
      return Image.file(
        current_user.image!,
        fit: BoxFit.cover,
      );
    }
  }
}
