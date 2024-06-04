import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/pages/change_number.dart';
import 'package:customer_app/pages/home_page.dart';
import 'package:customer_app/pages/signup_page.dart';
import 'package:customer_app/resources/auth_methods.dart';
import 'package:customer_app/utils/colors.dart';
import 'package:customer_app/utils/utils.dart';
import 'package:customer_app/widgets/text_field_input.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void fetch() async {
    setState(() {
      _isLoading = true;
    });
    await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get().then((map) {
      if (map.data()!.containsKey('phone')) {
        if (map.data()!['phone'] == null) {
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const ChangeNumberScreen(
                  from: 'google',
                ),
              ),
            );
          }
        } else if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
          );
        }
      } else if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ChangeNumberScreen(
              from: 'google',
            ),
          ),
        );
      }
    });

    if (context.mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void loginUser() async {
    setState(() {
      _isLoading = true;
    });

    String res = await AuthMethods().loginUser(
      email: _emailController.text,
      password: _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (res != "success" && context.mounted) {
      showSnackBar(res, context);
    } else if (context.mounted) {
      showSnackBar('Welcome back!', context);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  void navigateToSignUp() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const SignupScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: tealColor,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 128,
                ),
                const Image(
                  image: AssetImage('assets/8.png'),
                  height: 128,
                  width: 128,
                ),
                const SizedBox(height: 64),
                TextFieldInput(
                  icon: const Icon(
                    Icons.email_rounded,
                    color: Colors.black54,
                  ),
                  textEditingController: _emailController,
                  hintText: 'Enter your email',
                  textInputType: TextInputType.emailAddress,
                ),
                const SizedBox(
                  height: 12,
                ),
                TextFieldInput(
                  icon: const Icon(
                    Icons.password_rounded,
                    color: Colors.black54,
                  ),
                  textEditingController: _passwordController,
                  hintText: 'Enter your password',
                  textInputType: TextInputType.text,
                  isPass: true,
                ),
                const SizedBox(
                  height: 32,
                ),
                InkWell(
                  onTap: loginUser,
                  child: Container(
                    width: 150,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: const ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5),
                        ),
                      ),
                      color: Colors.tealAccent,
                    ),
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Log in',
                            style: TextStyle(
                              color: tealColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Container(
                          height: 0.5,
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          color: Colors.white70,
                        ),
                      ),
                      const Text(
                        'OR',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                          letterSpacing: 8,
                          fontSize: 16,
                        ),
                      ),
                      Flexible(
                        child: Container(
                          height: 0.8,
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  // width: MediaQuery,
                  // height: 80,
                  child: Transform.scale(
                    scale: 1.2,
                    child: SignInButton(
                      Buttons.Google,
                      onPressed: () async {
                        setState(() {
                          _isLoading = true;
                        });
                        String res = await AuthMethods().signInWithGoogle();
                        if (res != 'not selected') {
                          if (res != 'success' && context.mounted) {
                            showSnackBar(res, context);
                          } else {
                            fetch();
                          }
                        }
                        if (context.mounted) {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      },
                      text: 'Sign In with Google',
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 70,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                      child: const Text(
                        'Don\'t have an account?',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                      child: GestureDetector(
                        onTap: navigateToSignUp,
                        child: const Text(
                          'Sign up',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.tealAccent),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
