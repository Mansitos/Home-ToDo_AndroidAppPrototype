import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzData;

final _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

class LocalNoticeService {
  Future<void> setup() async {
    const androidSetting = AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(android: androidSetting, iOS: null);

    await _localNotificationsPlugin.initialize(initSettings).then((_) {
      debugPrint('setupPlugin: setup success');
    }).catchError((Object error) {
      debugPrint('Error: $error');
    });
  }

  Future<void> addNotification({id, title, body, date, channel}) async {
    tzData.initializeTimeZones();

    var endTime = date.millisecondsSinceEpoch;

    final scheduleTime = tz.TZDateTime.fromMillisecondsSinceEpoch(tz.local, endTime);
    final androidDetail = AndroidNotificationDetails(channel, channel, priority: Priority.max, importance: Importance.max);
    final noticeDetail = NotificationDetails(android: androidDetail);

    await _localNotificationsPlugin.zonedSchedule(id, title, body, scheduleTime, noticeDetail, uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, androidAllowWhileIdle: true);

    debugPrint(" > Scheduled Local Notification for task with ID: " + id.toString());
  }

  Future<void> cancelNotificationByID(id) async {
    await _localNotificationsPlugin.cancel(id);

    debugPrint(" > Deleted Scheduled Local Notification for task with ID: " + id.toString());
  }

  Future<void> cancelAllNotifications() async {
    await _localNotificationsPlugin.cancelAll();

    debugPrint(" > Deleted all Scheduled Local Notifications");
  }
}
