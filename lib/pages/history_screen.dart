import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int orders = 0;
  List<Map<String, dynamic>> orderSnap = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetch();
  }

  void fetch() async {
    setState(() {
      _isLoading = true;
    });
    await FirebaseFirestore.instance
        .collection('orders')
        .where(
          'uid',
          isEqualTo: FirebaseAuth.instance.currentUser!.uid,
        )
        .get()
        .then((value) {
      orders = value.size;
      orderSnap = List<Map<String, dynamic>>.from(value.docs.map((doc) => doc.data()));
    });
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('orders')
                .where(
                  'uid',
                  isEqualTo: FirebaseAuth.instance.currentUser!.uid,
                )
                .orderBy('datePlaced', descending: true)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return Scaffold(
                body: CustomScrollView(
                  slivers: [
                    const SliverAppBar(
                      floating: true,
                      elevation: 12,
                      backgroundColor: darkWhite,
                      shadowColor: lightGrey,
                      centerTitle: true,
                      automaticallyImplyLeading: false,
                      title: Text(
                        'Order History',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    snapshot.data!.docs.isNotEmpty
                        ? SliverList.builder(
                            itemCount: orders,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 16,
                                ),
                                child: Card(
                                  elevation: 4,
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
                                        dense: true,
                                        tileColor: lightGreen.withOpacity(0.9),
                                        title: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 16,
                                          ),
                                          child: Text(
                                            orderSnap[index]['resName'],
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        trailing: null,
                                      ),
                                      const Divider(
                                        height: 1,
                                        indent: 10,
                                        endIndent: 10,
                                      ),
                                      ListView.builder(
                                        padding: const EdgeInsets.all(0),
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: orderSnap[index]['orders'].length,
                                        itemBuilder: (context, itemIndex) => Column(
                                          children: [
                                            ListTile(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              dense: true,
                                              tileColor: lightGrey,
                                              title: Padding(
                                                padding: const EdgeInsets.only(
                                                  right: 16,
                                                ),
                                                child: Text(
                                                  orderSnap[index]['orders'][itemIndex],
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              // trailing: Text(
                                              //   orderSnap['prices'][index],
                                              //   style: const TextStyle(
                                              //     fontSize: 14,
                                              //     fontWeight: FontWeight.w500,
                                              //   ),
                                              // ),
                                            ),
                                            const Divider(
                                              height: 1,
                                              indent: 10,
                                              endIndent: 10,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(18),
                                        child: Row(
                                          children: [
                                            Text(
                                              '${DateFormat.yMMMMd().format(
                                                orderSnap[index]['datePlaced'].toDate(),
                                              )} at ${DateFormat.jm().format(
                                                orderSnap[index]['datePlaced'].toDate(),
                                              )}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                                color: Color.fromARGB(255, 74, 74, 74),
                                              ),
                                            ),
                                            Flexible(child: Container()),
                                            Text(
                                              '₹${orderSnap[index]['toPay']}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: parrotGreen,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                        : const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.only(top: 100),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.no_food_rounded,
                                    size: 40,
                                  ),
                                  Text('No Recent orders')
                                ],
                              ),
                            ),
                          ),
                  ],
                ),
              );
            });
  }
}
