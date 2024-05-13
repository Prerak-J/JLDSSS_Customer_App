import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/pages/edit_address_page.dart';
import 'package:customer_app/resources/address_methods.dart';
import 'package:customer_app/utils/colors.dart';
import 'package:customer_app/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
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
      content:
          const Text("Are you sure you want to delete this address? This action can't be undone."),
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

  void addAddress(String label, String address, String landmark) async {
    setState(() {
      _isLoading = true;
    });
    String res = await AddressMethods().addNewAddress(
      FirebaseAuth.instance.currentUser!.uid,
      {
        'label': label,
        'address': address,
        'landmark': landmark,
      },
    );
    if (context.mounted) {
      if (res != "success") {
        showSnackBar(res, context);
      } else {
        showSnackBar('Address added', context);
      }
    }
    setState(() {
      _labelController.clear();
      _addressController.clear();
      _landmarkController.clear();
      _isLoading = false;
    });
  }

  void deleteAddress(int index) async {
    Navigator.pop(context);
    setState(() {
      _isLoading = true;
    });
    String res =
        await AddressMethods().deleteAddressItem(FirebaseAuth.instance.currentUser!.uid, index);
    if (context.mounted) {
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
  void dispose() {
    super.dispose();
    _labelController.dispose();
    _addressController.dispose();
    _landmarkController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 226, 226, 226),
      appBar: AppBar(
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
                return Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          validator: (value) => value!.trim().isEmpty ? '*Required' : null,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          keyboardType: TextInputType.text,
                          controller: _labelController,
                          decoration: const InputDecoration(
                            labelText: 'Label*',
                            hintText: "Example: 'Home', 'Work', 'College' etc...",
                            hintStyle: TextStyle(fontSize: 14),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          validator: (value) => value!.trim().isEmpty ? '*Required' : null,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: _addressController,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            labelText: 'Address*',
                            hintText: 'Enter your full address',
                            hintStyle: TextStyle(fontSize: 14),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _landmarkController,
                          decoration: const InputDecoration(
                            labelText: 'Landmark (Optional)',
                            hintText:
                                'Example: Near Hotel Plaza, Behind Little Flowers School, etc...',
                            hintStyle: TextStyle(fontSize: 12),
                          ),
                        ),
                        const SizedBox(height: 40),
                        InkWell(
                          onTap: () {
                            if (_labelController.text.isNotEmpty &&
                                _addressController.text.isNotEmpty) {
                              addAddress(
                                _labelController.text,
                                _addressController.text,
                                _landmarkController.text,
                              );
                            } else {
                              showSnackBar('Please fill the Required(*) fields', context);
                            }
                          },
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
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w600),
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
                                                Text(snapshot.data!.data()!['addressList'][index]
                                                    ['address']),
                                                Text(snapshot.data!.data()!['addressList'][index]
                                                    ['landmark']),
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
                                                              addressSnap: snapshot.data!
                                                                  .data()!['addressList'][index],
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
    );
  }
}
