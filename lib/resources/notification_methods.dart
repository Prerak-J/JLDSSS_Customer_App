import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationMethods {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  void requestPermission() async {
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );
    if(settings.authorizationStatus == AuthorizationStatus.authorized){
      // PERMISSION GRANTED
    }
  }
}
