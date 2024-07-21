import 'package:customer_app/pages/home_page.dart';
import 'package:customer_app/resources/auth_methods.dart';
import 'package:customer_app/utils/colors.dart';
import 'package:customer_app/utils/utils.dart';
import 'package:customer_app/widgets/text_field_input.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChangeNumberScreen extends StatefulWidget {
  final String from;
  const ChangeNumberScreen({super.key, this.from = ''});

  @override
  State<ChangeNumberScreen> createState() => _ChangeNumberScreenState();
}

class _ChangeNumberScreenState extends State<ChangeNumberScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  // bool _checking = false;

  // @override
  // void initState() {
  //   if (widget.from == "google") {
  //     fetch();
  //   }
  //   super.initState();
  // }

  // void fetch() async {
  //   setState(() {
  //     _checking = true;
  //   });
  //   await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get().then((map) {
  //     if (map.data()!['phone'] != 'Add Number') {
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => const HomeScreen(),
  //         ),
  //       );
  //     }
  //   });

  //   setState(() {
  //     _checking = false;
  //   });
  // }

  void editProfile() async {
    setState(() {
      _isLoading = true;
    });
    String res = await AuthMethods().updateUserData(
      FirebaseAuth.instance.currentUser!.uid,
      {
        'phone': '+91${_phoneController.text}',
      },
    );
    setState(() {
      _isLoading = false;
    });

    if (res != "success" && mounted) {
      showSnackBar(res, context);
    } else if (mounted) {
      showSnackBar('Number updated', context);
      if (widget.from == 'google') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      } else {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _phoneController.dispose();
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
                      'Add/Change your number',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 26,
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    TextFieldInput(
                      icon: const Icon(
                        Icons.phone_android,
                        color: Colors.black54,
                      ),
                      textEditingController: _phoneController,
                      hintText: 'Enter your number',
                      textInputType: TextInputType.number,
                      prefixText: '+91',
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            widget.from == 'google'
                                ? showSnackBar('Phone number is required', context)
                                : Navigator.pop(context);
                          },
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
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
                                    'Update Number',
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
