import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserSelectionDropUpWidget extends StatefulWidget {
  const UserSelectionDropUpWidget({Key? key}) : super(key: key);

  @override
  State<UserSelectionDropUpWidget> createState() => UserSelectionDropUpWidgetState();
}

class UserSelectionDropUpWidgetState extends State<UserSelectionDropUpWidget> {
  int selectedUserIndex = 0;
  bool isVisible = false;

  changeIsVisible() => {isVisible = !isVisible};

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isVisible,
      child: Align(
        child: Container(
          height: 250,
          width: 70,
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Container(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemBuilder: (ctx, int) {
                    return Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5, top: 1, bottom: 0),
                        child: ElevatedButton(
                          child: const Text("A"),
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(shape: const CircleBorder(), fixedSize: const Size(20, 20)),
                        ));
                  },
                ),
              ),
            ),
          ),
        ),
        alignment: const FractionalOffset(0.25 / 4, 1),
      ),
    );
  }
}
