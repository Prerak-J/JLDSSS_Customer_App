import 'package:customer_app/resources/auth_methods.dart';
import 'package:customer_app/screens/otp_screen.dart';
import 'package:customer_app/utils/colors.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // bool _isLoading = false;
  showAlertDialog() {
    // set up the buttons
    Widget cancelButton = TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Text(
        "Cancel",
        style: TextStyle(color: parrotGreen),
      ),
    );
    Widget continueButton = TextButton(
      onPressed: () => Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => OtpScreen(
            buttonColor: Colors.red,
            purpose: 'Delete Profile',
            otpFuntion: AuthMethods().deleteUser,
          ),
        ),
      ),
      child: const Text(
        "Delete",
        style: TextStyle(color: Colors.red),
      ),
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text(
        "Delete Profile",
        style: TextStyle(color: parrotGreen),
      ),
      content: const Text(
        "You will lose all your data stored in this profile like order history, favourites, preferences etc.",
        maxLines: 4,
        textAlign: TextAlign.justify,
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  // void deleteProfile() async {
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   String res = await AuthMethods().deleteUser();
  //   setState(() {
  //     _isLoading = false;
  //   });
  //   if (context.mounted) {
  //     if (res == 'success') {
  //       showSnackBar('Profile deleted', context);
  //       Navigator.of(context).push(
  //         MaterialPageRoute(
  //           builder: (context) => const LoginScreen(),
  //         ),
  //       );
  //     } else {
  //       showSnackBar(res, context);
  //       Navigator.of(context).push(
  //         MaterialPageRoute(
  //           builder: (context) => const SettingsScreen(),
  //         ),
  //       );
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leadingWidth: 35,
        elevation: 7,
        shadowColor: lightGreen,
        backgroundColor: lightGreen,
        title: const Row(
          children: [
            Text(
              "Settings",
              style: TextStyle(
                color: Colors.black,
                fontSize: 23,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 10.0,
                    offset: Offset(4, 4),
                  ),
                ],
                color: Color.fromARGB(255, 220, 220, 220),
              ),
              child: Card(
                margin: const EdgeInsets.all(0),
                color: lightGrey,
                surfaceTintColor: lightGrey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      tileColor: lightGrey,
                      leading: const Icon(
                        Icons.edit,
                        color: Color.fromARGB(255, 31, 129, 34),
                      ),
                      title: const Text(
                        'Edit Profile',
                      ),
                      trailing: const Icon(Icons.keyboard_arrow_right),
                      onTap: () {},
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: double.infinity,
                      height: 0.5,
                      color: const Color.fromARGB(255, 196, 196, 196),
                    ),
                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      tileColor: lightGrey,
                      leading: const Icon(
                        Icons.delete_forever,
                        color: Colors.red,
                      ),
                      title: const Text(
                        'Delete Profile',
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                      // trailing: const Icon(Icons.keyboard_arrow_right),
                      onTap: showAlertDialog,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
