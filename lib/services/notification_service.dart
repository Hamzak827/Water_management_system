import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:water_management_system/main.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class PushNotifications {
  static final _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Request notification permissions for Firebase Messaging
  static Future<void> init() async {
    // Request notification permissions (FirebaseMessaging handles this for Android 13+)
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    print("Notification permissions: ${settings.authorizationStatus}");

    // Get the device's FCM token
    final token = await _firebaseMessaging.getToken();
    print("Device token: $token");
  }

  // Initialize local notifications
  static Future<void> localNotiInit() async {
    // Android settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
    );

    // Linux settings (optional)
    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open Notification');

    // Combine all platform settings
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux,
    );

    // Initialize the plugin
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: _onNotificationTap,
    );

    print("Local Notifications Initialized");
  }

  // Callback for foreground notifications on iOS
  static void _onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {
    print("Received local notification: $title, $body");
    // Add custom behavior here if needed (e.g., show a dialog)
  }

  // Callback when a local notification is tapped
  static void _onNotificationTap(NotificationResponse notificationResponse) {
    print("Notification tapped: ${notificationResponse.payload}");
    
  }

  //show a simple notification
 static Future showSimpleNotification({
  required String title,
  required String body,
  required String payload,
}) async {
  int notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
    'Your Channel id',
    'Your Channel Name',
    channelDescription: 'Your Channel Description',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
  );

  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails);

  await _flutterLocalNotificationsPlugin.show(
      notificationId, title, body, notificationDetails, payload: payload);
}

}
