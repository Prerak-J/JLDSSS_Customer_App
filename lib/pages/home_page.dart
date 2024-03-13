import 'package:customer_app/pages/delivery_page.dart';
import 'package:customer_app/pages/history_screen.dart';
import 'package:customer_app/pages/profile_page.dart';
import 'package:customer_app/resources/auth_methods.dart';
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
  var _userData = {};
  bool _isLoading = false;
  String address = '';
  int _page = 0;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    fetch();
    // print('I HAVE COME');
  }

  void fetch() async {
    setState(() {
      _isLoading = true;
    });
    _userData = (await AuthMethods().getUserData(
      FirebaseAuth.instance.currentUser!.uid,
    ))!;
    setState(() {
      _isLoading = false;
      address = _userData['address'];
    });
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
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
            backgroundColor: Colors.white,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(52),
              child: AppBar(
                elevation: 7,
                shadowColor: appBarGreen,
                backgroundColor: appBarGreen.withOpacity(0.96),
                automaticallyImplyLeading: false,
                title: Transform.translate(
                  offset: const Offset(0, 8),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          color: Colors.red,
                          size: 28,
                        ),
                        const SizedBox(
                          width: 2,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Home",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              address,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
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
