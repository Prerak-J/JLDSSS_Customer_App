import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/screens/map_screen.dart';
import 'package:customer_app/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ActiveOrderScreen extends StatefulWidget {
  const ActiveOrderScreen({super.key});

  @override
  State<ActiveOrderScreen> createState() => _ActiveOrderScreenState();
}

class _ActiveOrderScreenState extends State<ActiveOrderScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Orders'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('active', isEqualTo: true)
                  .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.no_food_rounded,
                          size: 40,
                        ),
                        Text('No Active Order')
                      ],
                    ),
                  );
                }
                return snapshot.data!.docs.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.no_food_rounded,
                              size: 40,
                            ),
                            Text('No Active Order')
                          ],
                        ),
                      )
                    : ListView.builder(
                      shrinkWrap: true,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          // name = snapshot.data!.docs[index].data()['name'];
                          // email = snapshot.data!.docs[index].data()['email'];
                          // phone = snapshot.data!.docs[index].data()['phone'];
                          // address = snapshot.data!.docs[index].data()['address'];
                          String orderId = '';
                          String otp = '';
                          String time = '';
                          String displayStatus = '';
                          orderId = snapshot.data!.docs[index].data()['OrderId'];
                          otp = snapshot.data!.docs[index].data()['CustomerPin'];
                          displayStatus = snapshot.data!.docs[index].data()['displayStatus'];
                          time = DateFormat.jm().format(
                            snapshot.data!.docs[index].data()['datePlaced'].toDate(),
                          );
                          return InkWell(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MapScreen(
                                  orderSnap: snapshot.data!.docs[index].data(),
                                ),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              child: Card(
                                elevation: 4,
                                margin: const EdgeInsets.all(0),
                                color: lightGrey,
                                surfaceTintColor: lightGrey,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              'Order ID: $orderId',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(
                                            displayStatus,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.blue[800],
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        'OTP: $otp',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: parrotGreen,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                        'Time of Order: $time',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: appBarGreen,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
              }),
        ),
      ),
    );
  }
}
