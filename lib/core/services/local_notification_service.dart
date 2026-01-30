import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: DarwinInitializationSettings(),
    );

    await _plugin.initialize( settings: settings);
  }

  static Future<void> showImageSaved() async {
    const androidDetails = AndroidNotificationDetails(
      'gallery_channel',
      'Gallery notifications',
      channelDescription: 'Notifications about saved images',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails =
    NotificationDetails(android: androidDetails);

    await _plugin.show(
      id: 0,
      title: 'Изображение сохранено',
      body: 'Ваш рисунок успешно сохранён в галерее',
      notificationDetails: notificationDetails,
    );
  }
}
