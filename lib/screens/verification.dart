import 'dart:async';

import 'package:customer_app/pages/home_page.dart';
import 'package:customer_app/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  bool _emailVerified = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Timer timer = Timer(Duration.zero, (){});

  @override
  void initState() {
    _emailVerified = _auth.currentUser!.emailVerified;
    if (_emailVerified) return;
    sendVerificationEmail();
    super.initState();
  }

  Future<void> sendVerificationEmail() async {
    final User? user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      if (mounted) {
        showSnackBar('Verification email sent', context);
      }
      handleEmailVerification();
    }
  }

  void handleEmailVerification() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      FirebaseAuth.instance.currentUser!.reload();
      if (FirebaseAuth.instance.currentUser!.emailVerified) {
        setState(() {
          _emailVerified = true;
          timer.cancel();
        });
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _emailVerified
        ? const HomeScreen()
        : Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: const Text('JLDSSS'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.mark_email_read_rounded,
                    size: 40,
                  ),
                  const Padding(
                    padding: EdgeInsets.all(11),
                    child: Text(
                      'Please verify your email ID to proceed\nA verification link has been sent to your email address.\n\nIf not auto redirected after confirmation, then click the Verified Button below',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: ElevatedButton(
                      onPressed: () {
                        FirebaseAuth.instance.currentUser!.reload();
                        if (FirebaseAuth.instance.currentUser!.emailVerified) {
                          setState(() {
                            _emailVerified = true;
                            // timer.cancel();
                          });
                        } else {
                          showSnackBar('Email not verified. Please check your mail.', context);
                        }
                      },
                      child: const Text('Verified'),
                    ),
                  )
                ],
              ),
            ),
          );
  }
}
