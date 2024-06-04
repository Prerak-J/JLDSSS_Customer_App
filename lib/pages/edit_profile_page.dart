import 'package:customer_app/resources/auth_methods.dart';
import 'package:customer_app/screens/otp_screen.dart';
import 'package:customer_app/utils/colors.dart';
import 'package:customer_app/widgets/text_field_input.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  var _userData = {};
  TextEditingController _emailController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  bool _isInitLoading = false;
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _nameController.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetch();
  }

  void fetch() async {
    setState(() {
      _isInitLoading = true;
    });
    _userData = (await AuthMethods().getUserData(
      FirebaseAuth.instance.currentUser!.uid,
    ))!;
    setState(() {
      _isInitLoading = false;
      _nameController = TextEditingController(text: _userData['name']);
      _emailController = TextEditingController(text: _userData['email']);
    });
  }

  void otpConfirm() async {
    setState(() {
      _isLoading = true;
    });
    String id = await AuthMethods().sendOtp(_userData['phone']);
    setState(() {
      _isLoading = false;
    });
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => OtpScreen(
            purpose: 'Edit Profile',
            name: _nameController.text,
            email: _emailController.text,
            verifyId: id,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: tealColor,
      body: _isInitLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 2,
                      child: Container(),
                    ),
                    const Image(
                      image: AssetImage('assets/8.png'),
                      height: 100,
                      width: 100,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'Edit your profile',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 30),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    TextFieldInput(
                      icon: const Icon(
                        Icons.person,
                        color: Colors.black54,
                      ),
                      textEditingController: _nameController,
                      hintText: 'Enter your name',
                      textInputType: TextInputType.text,
                    ),
                    const SizedBox(
                      height: 12,
                    ),
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
                      height: 32,
                    ),
                    Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
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
                              color: lightGrey,
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 2,
                          child: Container(),
                        ),
                        InkWell(
                          onTap: otpConfirm,
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
                                ? const CircularProgressIndicator()
                                : const Text(
                                    'Edit Profile',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                    Flexible(
                      flex: 2,
                      child: Container(),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
