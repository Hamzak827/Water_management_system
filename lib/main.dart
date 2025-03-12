import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water_management_system/providers/auth_provider.dart';
import 'package:water_management_system/providers/theme_provider.dart';
import 'package:water_management_system/navigation/app_navigator.dart';
import 'package:water_management_system/services/notification_service.dart';
import 'package:water_management_system/themes/app_themes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Background message handler
Future _firebaseBackgroundMessage(RemoteMessage message) async {
  if (message.notification != null) {
    print("Background notification received");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  
  await Firebase.initializeApp();
  

  await PushNotifications.init();
  await PushNotifications.localNotiInit();

  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);
  FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpened);
  FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

  final RemoteMessage? message =
      await FirebaseMessaging.instance.getInitialMessage();
  if (message != null) {
    print("App launched from terminated state");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
      ],
      child: const MyApp(),
    ),
  );
}



void _handleMessageOpened(RemoteMessage message) {
  print("Notification tapped");
  navigatorKey.currentState?.pushNamed("/message", arguments: message);
}

void _handleForegroundMessage(RemoteMessage message) {
  print("Foreground message received");
  if (message.notification != null) {
    PushNotifications.showSimpleNotification(
      title: message.notification!.title!,
      body: message.notification!.body!,
      payload: jsonEncode(message.data),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Water Management System',
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: themeNotifier.themeMode,
          navigatorKey: navigatorKey,
          home: AppNavigator(),
        );
      },
    );
  }
}

