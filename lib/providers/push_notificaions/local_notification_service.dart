import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  static Future<void> setup() async {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const androidSetting = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSetting = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidSetting, iOS: iosSetting);
    await _flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  static void showNewMessageLocalNotification(String title, String body) {
    const androidNotificationDetail = AndroidNotificationDetails(
        '0', // channel Id
        'general' // channel Name
        );
    const iosNotificatonDetail = DarwinNotificationDetails();
    const notificationDetails = NotificationDetails(
      iOS: iosNotificatonDetail,
      android: androidNotificationDetail,
    );
    _flutterLocalNotificationsPlugin.show(0, title, body, notificationDetails);
  }
}
