import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/pages/add_address_page.dart';
import 'package:customer_app/pages/edit_address_page.dart';
import 'package:customer_app/resources/address_methods.dart';
import 'package:customer_app/utils/colors.dart';
import 'package:customer_app/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddressScreen extends StatefulWidget {
  final String from;
  const AddressScreen({super.key, this.from = ''});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  bool _isLoading = false;

  showAlertDialog(int index) {
    // set up the buttons
    Widget cancelButton = TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Text(
        "Cancel",
        style: TextStyle(color: parrotGreen),
      ),
    );
    Widget continueButton = TextButton(
      onPressed: () => deleteAddress(index),
      child: const Text(
        "Delete Address",
        style: TextStyle(color: Colors.redAccent),
      ),
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text(
        "Delete Address",
        style: TextStyle(color: parrotGreen),
      ),
      content: const Text("Are you sure you want to delete this address? This action can't be undone."),
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

  void deleteAddress(int index) async {
    Navigator.pop(context);
    setState(() {
      _isLoading = true;
    });
    String res = await AddressMethods().deleteAddressItem(FirebaseAuth.instance.currentUser!.uid, index);
    if (mounted) {
      if (res != 'success') {
        showSnackBar(res, context);
      } else {
        showSnackBar('Address deleted', context);
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool _addressExist = true;
    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        automaticallyImplyLeading: widget.from != "menu",
        centerTitle: true,
        title: const Text(
          'Your Addresses',
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                int? currentIndex = snapshot.data!.data()!['defaultAddress'];
                snapshot.data!.data()!['addressList'] == null
                    ? _addressExist = false
                    : snapshot.data!.data()!['addressList'].length == 0
                        ? _addressExist = false
                        : _addressExist = true;

                return Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 40),
                        InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddAddressScreen(),
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            child: Material(
                              borderRadius: BorderRadius.circular(12),
                              elevation: 4,
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                width: MediaQuery.of(context).size.width * 0.5,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: const Color.fromARGB(255, 200, 243, 202),
                                ),
                                child: Text(
                                  'Add Address',
                                  style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        const Text(
                          'Added Addresses:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        snapshot.data!.data()!['addressList'] == null
                            ? const Center(
                                child: Text('No Added Addresses'),
                              )
                            : snapshot.data!.data()!['addressList'].length == 0
                                ? const Center(
                                    child: Text('No Added Addresses'),
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: snapshot.data!.data()!['addressList'].length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 3),
                                        child: Card(
                                          color: const Color.fromARGB(255, 214, 247, 214),
                                          elevation: 4,
                                          child: RadioListTile(
                                            controlAffinity: ListTileControlAffinity.trailing,
                                            contentPadding: const EdgeInsets.only(
                                              left: 10,
                                              top: 4,
                                              bottom: 4,
                                            ),
                                            title: Text(
                                              snapshot.data!.data()!['addressList'][index]['label'],
                                              style: const TextStyle(fontWeight: FontWeight.w600),
                                            ),
                                            subtitle: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(snapshot.data!.data()!['addressList'][index]['address']),
                                                Text(snapshot.data!.data()!['addressList'][index]['landmark']),
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    IconButton(
                                                      visualDensity: VisualDensity.compact,
                                                      onPressed: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) => EditAddressScreen(
                                                              addressIndex: index,
                                                              addressSnap: snapshot.data!.data()!['addressList'][index],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      icon: const Icon(Icons.edit),
                                                      iconSize: 20,
                                                    ),
                                                    IconButton(
                                                      visualDensity: VisualDensity.compact,
                                                      onPressed: () => showAlertDialog(index),
                                                      icon: Icon(
                                                        Icons.delete_forever_rounded,
                                                        color: Colors.red[800],
                                                      ),
                                                      iconSize: 20,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            value: index,
                                            groupValue: currentIndex,
                                            onChanged: (int? value) {
                                              if ((value ?? 0) >= 0) {
                                                FirebaseFirestore.instance
                                                    .collection('users')
                                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                                    .update({
                                                  'address':
                                                      "${snapshot.data!.data()!['addressList'][index]['label']}: ${snapshot.data!.data()!['addressList'][index]['address']}${snapshot.data!.data()!['addressList'][index]['landmark'] == '' ? '' : ', ${snapshot.data!.data()!['addressList'][index]['landmark']}'}",
                                                  'defaultAddress': index,
                                                });
                                                showSnackBar("Address set as Default", context);
                                              }
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                      ],
                    ),
                  ),
                );
              }),
      persistentFooterButtons: widget.from == "menu"
          ? [
              Center(
                child: InkWell(
                  onTap: () {
                    if (_addressExist) {
                      Navigator.pop(context);
                    } else {
                      showSnackBar('Please add an address first', context);
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.96,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.green[200],
                    ),
                    child: const Text(
                      'Select Address',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16.5,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              )
            ]
          : [],
    );
  }
}
