import 'package:customer_app/pages/login_page.dart';
import 'package:customer_app/pages/settings_page.dart';
import 'package:customer_app/resources/auth_methods.dart';
import 'package:customer_app/utils/colors.dart';
import 'package:customer_app/utils/utils.dart';
import 'package:customer_app/widgets/text_field_input.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OtpScreen extends StatefulWidget {
  final String verifyId;
  final String purpose;
  final Color buttonColor;
  final String name;
  final String email;
  const OtpScreen({
    super.key,
    this.purpose = 'Continue',
    this.buttonColor = Colors.tealAccent,
    this.name = '',
    this.email = '',
    required this.verifyId,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  void verifyOtp() {
    if (true) {
      otpFunction();
    }
  }

  void otpFunction() async {
    //DELETE PROFILE CONDITION
    if (widget.purpose == 'Delete Profile') {
      setState(() {
        _isLoading = true;
      });
      String res = await AuthMethods().deleteUser();
      setState(() {
        _isLoading = false;
      });
      if (context.mounted) {
        if (res == 'success') {
          showSnackBar('Profile deleted', context);
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
          );
        } else {
          showSnackBar(res, context);
          Navigator.of(context).pop();
        }
      }
    }

    //EDIT PROFILE CONDITION
    else if (widget.purpose == 'Edit Profile') {
      setState(() {
        _isLoading = true;
      });
      String res = await AuthMethods().updateUserData(
        FirebaseAuth.instance.currentUser!.uid,
        {
          'name': widget.name,
          'email': widget.email,
        },
      );
      setState(() {
        _isLoading = false;
      });

      if (res != "success" && context.mounted) {
        showSnackBar(res, context);
      } else if (context.mounted) {
        showSnackBar('Profile updated', context);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const SettingsScreen(),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _otpController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: tealColor,
      body: SafeArea(
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
                height: 128,
                width: 128,
              ),
              const SizedBox(
                height: 15,
              ),
              const Text(
                "We've sent you a 4-digit code to your registered mobile number",
                textAlign: TextAlign.center,
                maxLines: 1,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                "Enter OTP to ${widget.purpose}",
                textAlign: TextAlign.center,
                maxLines: 3,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 64),
              TextFieldInput(
                icon: const Icon(
                  Icons.system_security_update,
                  color: Colors.black54,
                ),
                textEditingController: _otpController,
                hintText: 'Enter OTP',
                textInputType: TextInputType.number,
                maxLength: 4,
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
                    onTap: verifyOtp,
                    child: Container(
                      width: 150,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: ShapeDecoration(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(5),
                          ),
                        ),
                        color: widget.buttonColor,
                      ),
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              widget.purpose,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                    child: const Text(
                      'Didn\'t get the OTP?',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                    child: GestureDetector(
                      onTap: () {},
                      child: const Text(
                        'Resend',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.tealAccent),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                child: GestureDetector(
                  onTap: () {},
                  child: const Text(
                    'Verify via password',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.tealAccent),
                  ),
                ),
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
