import 'dart:async';

import 'package:customer_app/resources/address_methods.dart';
import 'package:customer_app/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _addressController1 = TextEditingController();
  final Completer<GoogleMapController> _controller = Completer();
  bool _isLoading = false;
  Marker? _pickupMarker;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _setCurrentLocation();
  }

  Future<void> _setCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied && mounted) {
        Navigator.pop(context);
        showSnackBar("Location permission was denied", context);
      }
    }
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
      _pickupMarker = Marker(
        markerId: const MarkerId('pickup'),
        position: LatLng(position.latitude, position.longitude),
        infoWindow: const InfoWindow(title: 'Pickup Location'),
        draggable: true,
        onDragEnd: (newPosition) {
          setState(() {
            _pickupMarker = _pickupMarker!.copyWith(
              positionParam: newPosition,
            );
          });
        },
      );
    });
  }

  void addAddress(String label, String address, String landmark, LatLng position) async {
    setState(() {
      _isLoading = true;
    });

    String res = await AddressMethods().addNewAddress(
      FirebaseAuth.instance.currentUser!.uid,
      {
        'label': label,
        'address': address,
        'landmark': landmark,
        'latitude': position.latitude,
        'longitude': position.longitude,
      },
    );
    if (mounted) {
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
      Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _labelController.dispose();
    _addressController.dispose();
    _landmarkController.dispose();
    _addressController1.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 226, 226, 226),
      appBar: AppBar(
        elevation: 4,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.grey,
        title: const Text(
          'Add New Address',
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
                    const Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child: Center(
                        child: Text(
                          'Tap on the exact location for pickup\nYour order will be deilivered here',
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    _currentPosition == null
                        ? const SizedBox(
                            height: 350,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.only(bottom: 12),
                            constraints: const BoxConstraints(
                              minHeight: 350,
                              maxHeight: 350,
                            ),
                            child: Material(
                              elevation: 4,
                              child: GoogleMap(
                                gestureRecognizers: {
                                  Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer())
                                },
                                mapType: MapType.normal,
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                                  zoom: 15,
                                ),
                                markers: _pickupMarker != null ? {_pickupMarker!} : {},
                                onMapCreated: (GoogleMapController controller) {
                                  _controller.complete(controller);
                                },
                                onTap: (position) {
                                  setState(() {
                                    _pickupMarker = Marker(
                                      markerId: const MarkerId('pickup'),
                                      position: position,
                                      infoWindow: const InfoWindow(title: 'Pickup Location'),
                                      draggable: true,
                                      onDragEnd: (newPosition) {
                                        setState(() {
                                          _pickupMarker = _pickupMarker!.copyWith(
                                            positionParam: newPosition,
                                          );
                                        });
                                      },
                                    );
                                  });
                                },
                              ),
                            ),
                          ),
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
                        labelText: 'Address Line 1*',
                        hintText: 'Address Line 1',
                        hintStyle: TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _addressController1,
                      decoration: const InputDecoration(
                        labelText: 'Address Line 2 (Optional)',
                        hintText: 'Address Line 2',
                        hintStyle: TextStyle(fontSize: 12),
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
                            _addressController.text.isNotEmpty &&
                            _pickupMarker != null) {
                          addAddress(
                            _labelController.text,
                            _addressController.text +
                                (_addressController1.text.isNotEmpty ? ', ${_addressController1.text}' : ''),
                            _landmarkController.text,
                            _pickupMarker!.position,
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
                              style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600),
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
