import 'dart:io';
import 'package:customer_app/resources/notification_receive_methods.dart';
import 'package:customer_app/screens/flash_screen.dart';
import 'package:customer_app/utils/colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  final fcmService = FCMService();
  await fcmService.initialize();
  await dotenv.load(fileName: ".env/private.env");
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JLDSSS Customer App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: tealColor),
        useMaterial3: true,
      ),
      home: const FlashScreen(),
    );
  }
}
