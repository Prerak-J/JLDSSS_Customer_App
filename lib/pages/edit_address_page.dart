import 'package:customer_app/resources/address_methods.dart';
import 'package:customer_app/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditAddressScreen extends StatefulWidget {
  final int addressIndex;
  final Map<String, dynamic> addressSnap;
  const EditAddressScreen({
    super.key,
    required this.addressSnap,
    required this.addressIndex,
  });

  @override
  State<EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  TextEditingController _labelController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _landmarkController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.addressSnap['label']);
    _addressController = TextEditingController(text: widget.addressSnap['address']);
    _landmarkController = TextEditingController(text: widget.addressSnap['landmark']);
  }

  void editAddress(String label, String address, String landmark) async {
    setState(() {
      _isLoading = true;
    });
    String res = await AddressMethods().updateAddress(
      FirebaseAuth.instance.currentUser!.uid,
      widget.addressIndex,
      {
        'label': label,
        'address': address,
        'landmark': landmark,
      },
    );
    if (context.mounted) {
      if (res != 'success') {
        showSnackBar(res, context);
      } else {
        showSnackBar('Address updated', context);
        Navigator.pop(context);
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
          'Edit Address',
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
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
                        hintText: 'Example: Near Hotel Plaza, Behind Little Flowers School, etc...',
                        hintStyle: TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 40),
                    InkWell(
                      onTap: () {
                        if (_labelController.text.isNotEmpty &&
                            _addressController.text.isNotEmpty) {
                          editAddress(
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
                              'Edit Address',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }
}
