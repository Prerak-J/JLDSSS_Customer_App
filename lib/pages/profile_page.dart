import 'package:customer_app/pages/login_page.dart';
import 'package:customer_app/resources/auth_methods.dart';
import 'package:customer_app/utils/colors.dart';
import 'package:customer_app/utils/utils.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // bool _isLoading = false;
  // final FirebaseAuth _auth = FirebaseAuth.instance;

  void logoutUser() async {
    String res = await AuthMethods().logoutUser();

    if (context.mounted) {
      if (res == "success") {
        showSnackBar('Logged out', context);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      } else {
        showSnackBar(res, context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            alignment: Alignment.centerLeft,
            height: 150,
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 8,
            ),
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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Prerak',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'prerak@gmail.com',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(255, 31, 129, 34),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Card(
            margin: const EdgeInsets.all(0),
            color: lightGrey,
            surfaceTintColor: lightGrey,
            elevation: 8,
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
                    Icons.settings,
                    color: Color.fromARGB(255, 31, 129, 34),
                  ),
                  title: const Text(
                    'Settings',
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
                    Icons.logout_rounded,
                    color: Color.fromARGB(255, 31, 129, 34),
                  ),
                  title: const Text(
                    'Logout',
                  ),
                  trailing: const Icon(Icons.keyboard_arrow_right),
                  onTap: logoutUser,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// InkWell(
          //   onTap: logoutUser,
          //   child: Container(
          //     width: 150,
          //     // height: 50,
          //     alignment: Alignment.center,
          //     padding: const EdgeInsets.symmetric(vertical: 12),
          //     decoration: const ShapeDecoration(
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.all(
          //           Radius.circular(5),
          //         ),
          //       ),
          //       color: darkRed,
          //     ),
          //     child: _isLoading
          //         ? const Center(
          //             child: CircularProgressIndicator(
          //               color: Colors.white,
          //             ),
          //           )
          //         : const Text(
          //             'Log out',
          //             style: TextStyle(
          //               color: Colors.white,
          //               fontWeight: FontWeight.w600,
          //             ),
          //           ),
          //   ),
          // ),