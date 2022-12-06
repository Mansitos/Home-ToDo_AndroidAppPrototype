import 'dart:async';
import 'package:flutter/material.dart';
import 'package:home_to_do/utilities/globals.dart' as globals;

void showPopUpMessage(BuildContext context,String message, int? time, {int additionalPops: 0}){
// Animation time...
  if (globals.popUpMessagesEnabled == true) {
    Timer? _timer;
    int _autoCloseTimer = 1000;

    if (time != null) {
      _autoCloseTimer = time;
    }

    showDialog(
        context: context,
        builder: (BuildContext context) {
          _timer = Timer(Duration(milliseconds: _autoCloseTimer), () {
            for(int i=0; i<additionalPops+1;i++) {
              Navigator.of(context).pop();
            }
          });
          return AlertDialog(
            title: Center(
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                )),
          );
        }).then((val) {
      if (_timer!.isActive) {
        _timer!.cancel();
      }
    });
  }else{
    for(int i=0; i<additionalPops;i++) {
      Navigator.of(context).pop();
    }
  }
}