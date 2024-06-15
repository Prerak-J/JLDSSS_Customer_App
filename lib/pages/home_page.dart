import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/pages/address_page.dart';
import 'package:customer_app/pages/delivery_page.dart';
import 'package:customer_app/pages/history_screen.dart';
import 'package:customer_app/pages/profile_page.dart';
import 'package:customer_app/resources/notification_methods.dart';
import 'package:customer_app/screens/map_screen.dart';
import 'package:customer_app/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    pageController = PageController();
    NotificationMethods().requestPermission();
    super.initState();
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
      backgroundColor: darkWhite,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: AppBar(
          elevation: 7,
          shadowColor: appBarGreen,
          backgroundColor: appBarGreen.withOpacity(0.96),
          automaticallyImplyLeading: false,
          title: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                return Transform.translate(
                  offset: const Offset(0, 7),
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddressScreen()),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            color: Colors.red,
                            size: 28,
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                          Flexible(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  snapshot.data!.data()!['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  snapshot.data!.data()!['address'] ?? 'Add Address',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.greenAccent,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
          actions: [
            Container(
              height: 30,
              width: 40,
              padding: const EdgeInsets.only(right: 8),
              child: FloatingActionButton(
                mini: true,
                onPressed: () {
                  // showSnackBar('Work in Progress !', context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MapScreen()),
                  );
                },
                child: const Icon(
                  Icons.delivery_dining_rounded,
                  size: 20,
                ),
              ),
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
          HistoryScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: CupertinoTabBar(
        onTap: navigationTapped,
        backgroundColor: Colors.white,
        currentIndex: _page,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dinner_dining_rounded),
            label: 'Home',
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
