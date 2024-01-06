import 'package:customer_app/utils/colors.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: appBarGreen,
        automaticallyImplyLeading: false,
        title: const Row(
          children: [
            Icon(
              Icons.location_on_rounded,
              color: Colors.red,
              size: 30,
            ),
            SizedBox(
              width: 2,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Home",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
                ),
                Text(
                  'Khatra mahal, Shaitan gali, Shamshaan ke...',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text(
          'HOMMMEEEE SCREEEENNN',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
