import 'package:customer_app/pages/delivery_page.dart';
import 'package:customer_app/pages/profile_page.dart';
import 'package:customer_app/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _page = 0;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    // print('I HAVE COME');
  }

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
    // print('I HAVE COME AGAIN');
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
    // print('Page $_page');
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 7,
        shadowColor: appBarGreen,
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
      body: PageView(
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          DeliveryScreen(),
          Center(
            child: Text(
              'HISTORRYYY SCREEEENNN',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: CupertinoTabBar(
        onTap: navigationTapped,
        backgroundColor: Colors.white,
        currentIndex: _page,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.delivery_dining),
            label: 'Delivery',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
