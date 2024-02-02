import 'package:customer_app/resources/auth_methods.dart';
import 'package:customer_app/utils/colors.dart';
import 'package:customer_app/utils/utils.dart';
import 'package:customer_app/widgets/text_field_input.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  var _userData = {};
  final TextEditingController _oldPassController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  bool _isLoading = false;

  void editProfile() async {
    setState(() {
      _isLoading = true;
    });
    _userData = (await AuthMethods().getUserData(
      FirebaseAuth.instance.currentUser!.uid,
    ))!;
    String res = 'Some error occured';
    if (_oldPassController.text == _userData['password']) {
      res = await AuthMethods().updateUserData(
        FirebaseAuth.instance.currentUser!.uid,
        {
          'password': _newPassController.text,
        },
      );
    } else if (context.mounted) {
      showSnackBar('Incorrect old password', context);
    }
    setState(() {
      _isLoading = false;
    });

    if (res != "success" && context.mounted) {
      showSnackBar(res, context);
    } else if (context.mounted) {
      showSnackBar('Password changed', context);
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _oldPassController.dispose();
    _newPassController.dispose();
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
                height: 100,
                width: 100,
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                'Change your password',
                style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 30),
              ),
              const SizedBox(
                height: 30,
              ),
              TextFieldInput(
                icon: const Icon(
                  Icons.password,
                  color: Colors.black54,
                ),
                textEditingController: _oldPassController,
                hintText: 'Enter old password',
                textInputType: TextInputType.text,
              ),
              const SizedBox(
                height: 12,
              ),
              TextFieldInput(
                icon: const Icon(
                  Icons.password,
                  color: Colors.black54,
                ),
                textEditingController: _newPassController,
                hintText: 'Enter new password',
                textInputType: TextInputType.text,
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
                    onTap: editProfile,
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
                              'Change password',
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
