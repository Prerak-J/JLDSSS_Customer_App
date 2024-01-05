// import 'package:customer_app/pages/home_page.dart';
import 'package:customer_app/pages/login_page.dart';
import 'package:customer_app/utils/colors.dart';
import 'package:flutter/material.dart';

class FlashScreen extends StatefulWidget {
  const FlashScreen({super.key});

  @override
  State<FlashScreen> createState() => _FlashScreenState();
}

class _FlashScreenState extends State<FlashScreen> {
  @override
  void initState() {
    super.initState();
    print('I HAVE BEEN SUMMONED');
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 1200), () {});
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return const LoginScreen();
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: tealColor,
      body: Center(
        child: Image(
          image: AssetImage('assets/8.png'),
          height: 200,
          width: 200,
        ),
      ),
    );
  }
}
