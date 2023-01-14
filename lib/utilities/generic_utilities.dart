// In this file, generic functions are defined

import 'package:flutter/material.dart';
import '../data_types/task.dart';

extension StringExtension on String {
  String capitalize() {
    if (this.length > 0) {
      return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
    } else {
      return this;
    }
  }
}

String monthToText(int month, {bool extendedMode = false}) {
  switch (month) {
    case 1:
      return extendedMode == false ? ("Jan") : ("January");
    case 2:
      return extendedMode == false ? ("Feb") : ("February");
    case 3:
      return extendedMode == false ? ("Mar") : ("March");
    case 4:
      return extendedMode == false ? ("Apr") : ("April");
    case 5:
      return extendedMode == false ? ("May") : ("May");
    case 6:
      return extendedMode == false ? ("Jun") : ("June");
    case 7:
      return extendedMode == false ? ("Jul") : ("July");
    case 8:
      return extendedMode == false ? ("Aug") : ("August");
    case 9:
      return extendedMode == false ? ("Sep") : ("September");
    case 10:
      return extendedMode == false ? ("Oct") : ("October");
    case 11:
      return extendedMode == false ? ("Nov") : ("November");
    case 12:
      return extendedMode == false ? ("Dec") : ("December");
    default:
      return ("ERROR");
  }
}

String hourToString(TimeOfDay selectedHour) {
  if (selectedHour.minute >= 10) {
    return selectedHour.hour.toString() + ":" + selectedHour.minute.toString();
  } else {
    return selectedHour.hour.toString() + ":0" + selectedHour.minute.toString();
  }
}

String encodeDate(DateTime date) {
  return date.toString();
}

String encodeTime(TimeOfDay time) {
  String encode = time.hour.toString() + "-" + time.minute.toString();
  return encode;
}

DateTime decodeDate(String encode) {
  DateTime date = DateTime.parse(encode);
  return date;
}

TimeOfDay decodeTime(String encode) {
  List<String> data = encode.split('-');
  return TimeOfDay(hour: int.parse(data[0]), minute: int.parse(data[1]));
}

String encodeBool(bool val) {
  if (val == true) {
    return "true";
  } else {
    return "false";
  }
}

bool decodeBool(String val) {
  if (val == "true") {
    return true;
  } else if (val == "false") {
    return false;
  } else {
    debugPrint("Error in decoding encoded bool: " + val + "    false will be returned!");
    return false;
  }
}

extension TimeOfDayExtension on TimeOfDay {
  // Ported from org.threeten.bp;
  TimeOfDay plusMinutes(int minutes) {
    if (minutes == 0) {
      return this;
    } else {
      int mofd = this.hour * 60 + this.minute;
      int newMofd = ((minutes % 1440) + mofd + 1440) % 1440;
      if (mofd == newMofd) {
        return this;
      } else {
        int newHour = newMofd ~/ 60;
        int newMinute = newMofd % 60;
        return TimeOfDay(hour: newHour, minute: newMinute);
      }
    }
  }
}

bool checkDateLimit(Task task, DateTime? endDate, DateTime startingDate) {
  if (endDate == null) {
    // It's not a range check.
    return areSameDay(startingDate, task.dateLimit);
  } else if ((task.dateLimit.isBefore(endDate) || areSameDay(task.dateLimit, endDate)) && (startingDate.isBefore(task.dateLimit)) || areSameDay(startingDate, task.dateLimit)) {
    // It's a range check!
    return true;
  } else {
    return false;
  }
}

bool areSameDay(DateTime first, DateTime second) {
  return (first.year == second.year && first.month == second.month && first.day == second.day);
}

String dateToString(DateTime date) {
  DateTime today = DateTime.now();
  DateTime yesterday = today.subtract(Duration(days: 1));
  DateTime tomorrow = today.add(Duration(days: 1));

  if (date.toString() == DateTime(0).toString()) {
    return "--";
  }
  if (date.year == today.year && date.month == today.month && date.day == today.day) {
    // Today case
    return "Today";
  } else if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) {
    // Yesterday case
    return "Yesterday";
  } else if (date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day) {
    // Tomorrow case
    return "Tomorrow";
  } else {
    return date.day.toString() + "/" + date.month.toString() + "/" + date.year.toString();
  }
}
