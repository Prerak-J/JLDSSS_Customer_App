import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  Platform.isAndroid
      ? await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: 'AIzaSyA5t5TYXpSCCzlSBlU10cmdyREPGxqsTJQ',
            appId: '1:421635814264:android:b5067866e08e1bdcd14e8d',
            messagingSenderId: '421635814264',
            projectId: 'jldsss-customer-app',
          ),
        )
      : await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

class FCMService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  final AndroidNotificationChannel _orderChannel = const AndroidNotificationChannel(
    'order_status_channel',
    'Order Status',
    description: 'Notifications about your order status',
    importance: Importance.high,
  );

  // final AndroidNotificationChannel _offerChannel = const AndroidNotificationChannel(
  //   'offer_channel',
  //   'Special Offers',
  //   description: 'Notifications about special offers and promotions',
  //   importance: Importance.defaultImportance,
  // );

  Future<void> initialize() async {
    Platform.isAndroid
        ? await Firebase.initializeApp(
            options: const FirebaseOptions(
              apiKey: 'AIzaSyA5t5TYXpSCCzlSBlU10cmdyREPGxqsTJQ',
              appId: '1:421635814264:android:b5067866e08e1bdcd14e8d',
              messagingSenderId: '421635814264',
              projectId: 'jldsss-customer-app',
            ),
          )
        : await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_orderChannel);
    // await _flutterLocalNotificationsPlugin
    //     .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
    //     ?.createNotificationChannel(_offerChannel);

    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');

      String? token = await _firebaseMessaging.getToken();
      try {
        if (FirebaseAuth.instance.currentUser != null) {
          await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update(
            {'fcmToken': token},
          );
        }
      } on FirebaseException catch (e) {
        print(e.message ?? 'ERROR');
      }
      print('FCM Token: $token');

      FirebaseMessaging.onMessage.listen(_handleMessage);
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print("Notification tapped when app was in background");
        // Handle notification tap
      });

      RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        print("App opened from terminated state via notification");
        // Handle notification tap
      }
    } else {
      print('User declined or has not accepted permission');
    }
  }

  Future<void> _handleMessage(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      AndroidNotificationDetails androidPlatformChannelSpecifics;

      if (message.data['type'] == 'order_status') {
        androidPlatformChannelSpecifics = AndroidNotificationDetails(
          _orderChannel.id,
          _orderChannel.name,
          channelDescription: _orderChannel.description,
          importance: Importance.high,
          priority: Priority.high,
        );
      }
      // else if (message.data['type'] == 'offer') {
      //   androidPlatformChannelSpecifics = AndroidNotificationDetails(
      //     _offerChannel.id,
      //     _offerChannel.name,
      //     channelDescription: _offerChannel.description,
      //     importance: Importance.defaultImportance,
      //     priority: Priority.defaultPriority,
      //   );
      // }
      else {
        androidPlatformChannelSpecifics = const AndroidNotificationDetails(
          'default_channel',
          'Default Notifications',
          channelDescription: 'For all other notifications',
          importance: Importance.low,
          priority: Priority.low,
        );
      }

      await _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(android: androidPlatformChannelSpecifics),
        payload: message.data['payload'],
      );
    }
  }
}
