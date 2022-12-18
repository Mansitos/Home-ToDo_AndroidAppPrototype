import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_to_do/data_types/user.dart';
import 'package:home_to_do/utilities/globals.dart' as globals;

class UserSelectionDropUpWidget extends StatefulWidget {
  UserSelectionDropUpWidget({Key? key, required this.onUserSelected}) : super(key: key);

  final userSelectedCallback onUserSelected;

  @override
  State<UserSelectionDropUpWidget> createState() => UserSelectionDropUpWidgetState();
}

typedef void userSelectedCallback(User user);

class UserSelectionDropUpWidgetState extends State<UserSelectionDropUpWidget> {
  int selectedUserIndex = 0;
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
          height: screenHeight * 0.275,
          width: screenWidth * 0.175,
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(screenWidth * 0.04)),
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
      Widget selector = Padding(
          padding: EdgeInsets.all(screenWidth * 0.01),
          child: Column(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                icon: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                    child: ClipOval(
                      child: SizedBox.fromSize(size: Size.fromRadius(screenWidth * 0.05), child: _getUserImage(i)),
                    )),
                onPressed: () {
                  userSelected(globals.users[i]);
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
                globals.users[i].name,
                style: TextStyle(fontSize: 12),
              )
            ],
          ));
      userSelectors.add(selector);
    }

    return userSelectors;
  }

  _getUserImage(int i) {
    if (i == 0) {
      return Image.asset(
        "lib/assets/user_images/default_users_img.png",
        fit: BoxFit.cover,
      );
    }
    if (globals.users[i].image == null) {
      return Image.asset(
        "lib/assets/user_images/default_user_img.png",
        fit: BoxFit.cover,
      );
    } else {
      return Image.file(
        globals.users[i].image!,
        fit: BoxFit.cover,
      );
    }
  }
}
