import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:water_management_system/main.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class PushNotifications {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String vapidKey =
      "BP4Jjmmxp_pjY26cUEHRUq489pY9il2_tHvFePfIA8ADfT8Dgwgi88-4yKQzeaxtqR8DoWITVaF5_wRRdIC1z1s";

  static Future<void> init() async {
    // Request permissions
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    // Get and handle FCM token with VAPID key
    try {
      final token = await _firebaseMessaging.getToken(vapidKey: vapidKey);
      print("FCM Token: $token");
      // Store or send token to your server here
    } catch (e) {
      print("Error getting FCM token: $e");
    }
  }

  static Future<void> localNotiInit() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  static void _onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {
    print("Received local notification: $title");
  }

  static void _onNotificationTap(NotificationResponse response) {
    print("Notification tapped: ${response.payload}");
    // navigatorKey.currentState?.pushNamed("/notifications");
  }

  static Future showSimpleNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'channel_id',
      'Channel Name',
      channelDescription: 'Channel Description',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      platformDetails,
      payload: payload,
    );
  }
}
