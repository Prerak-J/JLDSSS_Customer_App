import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/screens/ratings_screen.dart';
import 'package:customer_app/utils/colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:widget_to_marker/widget_to_marker.dart';

class MapScreen extends StatefulWidget {
  final Map<String, dynamic> orderSnap;
  const MapScreen({super.key, required this.orderSnap});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  final CollectionReference _orderCollection = FirebaseFirestore.instance.collection('orders');
  final CollectionReference _partnerCollection = FirebaseFirestore.instance.collection('partners');
  LatLng _destination = const LatLng(37.77483, -122.41942); // Example destination
  LatLng _currentPosition = const LatLng(0.0, 0.0);
  LatLng _restaurantPosition = const LatLng(0.0, 0.0);
  double _remainingDistance = 1000.0;
  Timer _timer = Timer(Duration.zero, () {});
  Map<String, dynamic> orderSnap = {};
  Map<String, dynamic> partnerSnap = {};
  Map<String, dynamic> restaurantSnap = {};
  BitmapDescriptor deliveryBoyIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor restaurantIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);

  bool _isLoading = false;
  // bool _buttonLoading = false;
  final bool _noActiveOrder = false;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  void _fetch() async {
    setState(() {
      _isLoading = true;
    });

    // await FirebaseFirestore.instance
    //     .collection('orders')
    //     .where('active', isEqualTo: true)
    //     .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
    //     .limit(1)
    //     .get()
    //     .then((orderMap) {
    //   if (orderMap.size == 0 && context.mounted) {
    //     setState(() {
    //       _isLoading = false;
    //       _noActiveOrder = true;
    //     });
    //     return;
    //   } else {
    //     orderSnap = Map.from(orderMap.docs[0].data());
    //     _destination = LatLng(orderSnap['lat'], orderSnap['lng']);
    //     _startLocationTracking();
    //   }
    // });

    orderSnap = Map.from(widget.orderSnap);
    _destination = LatLng(orderSnap['lat'], orderSnap['lng']);
    _startLocationTracking();

    await FirebaseFirestore.instance.collection('restaurants').doc(orderSnap['resUid']).get().then((value) {
      restaurantSnap = Map.from(value.data()!);
      _restaurantPosition = LatLng(restaurantSnap['lat'], restaurantSnap['lng']);
    });

    deliveryBoyIcon = await Icon(
      Icons.delivery_dining_rounded,
      size: 90,
      color: Colors.red[900],
    ).toBitmapDescriptor();

    restaurantIcon = await Icon(
      Icons.restaurant_menu_rounded,
      size: 90,
      color: Colors.orange[700],
    ).toBitmapDescriptor();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // showAlertDialog(String displayStatus) {
  //   // set up the buttons
  //   Widget cancelButton = TextButton(
  //     onPressed: () => Navigator.pop(context),
  //     child: const Text(
  //       "Cancel",
  //       style: TextStyle(color: parrotGreen),
  //     ),
  //   );
  //   Widget continueButton = TextButton(
  //     onPressed: () async {
  //       Navigator.pop(context);
  //       setState(() {
  //         _buttonLoading = true;
  //       });
  //       await FirebaseFirestore.instance.collection('orders').doc(orderSnap['orderId']).update({
  //         'confirmDelivery': true,
  //       });
  //       setState(() {
  //         _buttonLoading = false;
  //       });
  //       if (mounted) {
  //         showSnackBar('Delivery Completed', context);
  //         Navigator.pushReplacement(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => RatingsScreen(
  //               orderSnap: orderSnap,
  //               partnerSnap: partnerSnap,
  //               restaurantSnap: restaurantSnap,
  //             ),
  //           ),
  //         );
  //       }
  //       // if (mounted) {
  //       //   Navigator.pop(context);
  //       //   showSnackBar('Delivery Completed. Great Job!', context);
  //       // }
  //     },
  //     child: Text(
  //       "Confirm",
  //       style: TextStyle(color: Colors.red[800]),
  //     ),
  //   );
  //   // set up the AlertDialog
  //   AlertDialog alert = AlertDialog(
  //     title: const Text(
  //       "Confirm Order?",
  //       style: TextStyle(color: parrotGreen),
  //     ),
  //     content: const Text(
  //       "Are you sure you have recieved your order? You will be responsible for any future conflicts. This action can't be undone.",
  //       textAlign: TextAlign.justify,
  //     ),
  //     actions: [
  //       cancelButton,
  //       continueButton,
  //     ],
  //   );
  //   // show the dialog
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return alert;
  //     },
  //   );
  // }

  void _startLocationTracking() {
    _startDistanceCalculation();
    _orderCollection.doc(widget.orderSnap['orderId']).snapshots().listen((snapshot) {
      setState(() {
        orderSnap = Map.from(snapshot.data() as Map<String, dynamic>);
      });
      if (!orderSnap['active'] && orderSnap['confirmDelivery']) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RatingsScreen(
              orderSnap: orderSnap,
              partnerSnap: partnerSnap,
              restaurantSnap: restaurantSnap,
            ),
          ),
        );
      } else if (!orderSnap['active']) {
        Navigator.pop(context);
      }
    });
    _partnerCollection.snapshots().listen((snapshot) {
      Map<String, dynamic> partnerData = {};
      bool partnerExist = snapshot.docs.any((partner) {
        partnerData = Map.from(partner.data() as Map<String, dynamic>);
        if (partnerData['orderId'] == orderSnap['orderId']) {
          return true;
        } else {
          partnerData.clear();
          return false;
        }
      });
      if (partnerExist) {
        final data = partnerData;
        partnerSnap = Map.from(partnerData);
        // print("NAAAAAMEEEEEE: ${data['name']}");
        final newPosition = LatLng(data['lat'], data['lng']);
        setState(() {
          _currentPosition = newPosition;
        });
        _mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: newPosition,
              zoom: 11.2,
            ),
          ),
        );
      } else {
        setState(() {
          _currentPosition = const LatLng(0.0, 0.0);
        });
      }
    });
  }

  void _calculateRemainingDistance() {
    // print("DEST: $_destination");
    // print("CURR: $_currentPosition");
    if (_currentPosition != const LatLng(0.0, 0.0)) {
      final distance = Geolocator.distanceBetween(
        _currentPosition.latitude,
        _currentPosition.longitude,
        _destination.latitude,
        _destination.longitude,
      );
      setState(() {
        _remainingDistance = distance / 1000; // Convert to kilometers
      });
    }
  }

  void _startDistanceCalculation() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _calculateRemainingDistance();
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _mapController.showMarkerInfoWindow(const MarkerId('You'));
  }

  @override
  Widget build(BuildContext context) {
    Set<Marker> markers = {
      Marker(
        markerId: const MarkerId('You'),
        position: _destination,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: "You"),
      ),
      Marker(
        markerId: const MarkerId('Restaurant'),
        position: _restaurantPosition,
        icon: restaurantIcon,
        infoWindow: const InfoWindow(title: "Restaurant"),
      ),
    };
    if (_currentPosition != const LatLng(0.0, 0.0)) {
      markers.add(
        Marker(
          markerId: const MarkerId('Delivery Boy'),
          position: _currentPosition,
          infoWindow: const InfoWindow(title: "Delivery Boy"),
          icon: deliveryBoyIcon,
        ),
      );
      setState(() {
        partnerSnap;
      });
    } else if (markers.length == 3) {
      markers.removeWhere(
        (mark) => mark.markerId == const MarkerId('Delivery Boy'),
      );
    }
    return _isLoading
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : _noActiveOrder
            ? Scaffold(
                appBar: AppBar(),
                body: const Center(
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
                ),
              )
            : Scaffold(
                resizeToAvoidBottomInset: true,
                backgroundColor: darkWhite,
                appBar: AppBar(
                  backgroundColor: darkWhite,
                  surfaceTintColor: Colors.transparent,
                  elevation: 4,
                  shadowColor: Colors.grey[350],
                  title: const Text(
                    'Delivery Tracking',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                body: (orderSnap.isEmpty)
                    ? const Center(child: Text('No Active Order'))
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(12, 14, 12, 4),
                              child: Text(
                                'Order OTP: ${orderSnap['CustomerPin']}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: parrotGreen,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(12, 14, 12, 4),
                              child: Text(
                                'Order Status: ${orderSnap['displayStatus']}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: parrotGreen,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              constraints: const BoxConstraints(
                                minHeight: 400,
                                maxHeight: 400,
                              ),
                              child: Material(
                                elevation: 8,
                                child: GoogleMap(
                                  zoomControlsEnabled: false,
                                  onMapCreated: _onMapCreated,
                                  gestureRecognizers: {
                                    Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer())
                                  },
                                  initialCameraPosition: CameraPosition(
                                    target: _destination,
                                    zoom: 11.0,
                                  ),
                                  markers: markers,
                                ),
                              ),
                            ),
                            _remainingDistance == 1000.0
                                ? Container()
                                : Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      height: 30,
                                      decoration: BoxDecoration(
                                          color: Colors.tealAccent, borderRadius: BorderRadius.circular(4)),
                                      child: Center(
                                        child: Text(
                                          'Remaining distance: ${_remainingDistance.toStringAsFixed(1)} km',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                            Padding(
                              padding: const EdgeInsets.all(12),
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
                                          orderSnap['resName'],
                                          style: const TextStyle(
                                            fontSize: 16,
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
                                      itemCount: orderSnap['orders'].length,
                                      itemBuilder: (context, index) => Column(
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
                                                orderSnap['orders'][index],
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            trailing: Text(
                                              orderSnap['prices'][index],
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          const Divider(
                                            height: 1,
                                            indent: 10,
                                            endIndent: 10,
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(18),
                                      child: Row(
                                        children: [
                                          Text(
                                            '${DateFormat.yMMMMd().format(
                                              orderSnap['datePlaced'].toDate(),
                                            )} at ${DateFormat.jm().format(
                                              orderSnap['datePlaced'].toDate(),
                                            )}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                              color: Color.fromARGB(255, 74, 74, 74),
                                            ),
                                          ),
                                          Flexible(child: Container()),
                                          Text(
                                            'Total: ₹${orderSnap['total']}',
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
                            ),
                            const Padding(
                              padding: EdgeInsets.fromLTRB(12, 12, 12, 1),
                              child: Text(
                                'Ordered by :',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(12, 1, 12, 12),
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
                                      Text(
                                        orderSnap['name'],
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        orderSnap['email'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Color.fromARGB(255, 31, 129, 34),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                        orderSnap['phone'],
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      Text(
                                        orderSnap['address'],
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          color: Colors.black54,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            partnerSnap.isEmpty
                                ? Container()
                                : const Padding(
                                    padding: EdgeInsets.fromLTRB(15, 12, 15, 2),
                                    child: Text(
                                      'Your Delivery Partner :',
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                            partnerSnap.isEmpty
                                ? Container()
                                : Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
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
                                            Text(
                                              partnerSnap['name'],
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              partnerSnap['phone'],
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: parrotGreen,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                            const Padding(
                              padding: EdgeInsets.fromLTRB(15, 12, 15, 2),
                              child: Text(
                                'Bill Summary :',
                                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 16, color: appBarGreen),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 2,
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
                                          const Text(
                                            'Item total',
                                            style: TextStyle(
                                              fontSize: 14,
                                              // fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            '₹${orderSnap['total'].toString()}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              // fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'GST',
                                            style: TextStyle(
                                              fontSize: 14,
                                              // fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            '₹${((orderSnap['gst'] * orderSnap['total']) / 100).toString()}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              // fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Delivery partner fee for 5 km',
                                            style: TextStyle(
                                              fontSize: 14,
                                              // fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            '₹${orderSnap['deliveryFee']}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              // fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Platform fee',
                                            style: TextStyle(
                                              fontSize: 14,
                                              // fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            '₹${orderSnap['platformFee']}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              // fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      const Divider(
                                        thickness: 1,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Grand Total',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            '₹${orderSnap['grdTotal'].toString()}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            orderSnap.containsKey('couponApplied')
                                                ? orderSnap['couponApplied'].isNotEmpty
                                                    ? 'Coupon Applied - (${orderSnap['couponApplied']['name']})'
                                                    : 'No Coupon Applied'
                                                : 'No Coupon Applied',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              // fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            orderSnap.containsKey('couponApplied')
                                                ? '- ₹${(orderSnap['grdTotal'] - orderSnap['toPay']).toStringAsFixed(1)}'
                                                : '-  ₹0.0',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              // fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Final amount',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            '₹${orderSnap['toPay'].toString()}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 100,
                            ),
                          ],
                        ),
                      ),
                floatingActionButton: FloatingActionButton(
                  onPressed: _calculateRemainingDistance,
                  tooltip: 'Refresh Location',
                  child: const Icon(Icons.refresh),
                ),
                // persistentFooterButtons: [
                //   Center(
                //     child: InkWell(
                //       onTap: () {
                //         if (partnerSnap.isEmpty) {
                //           showSnackBar('Delivery Partner not assigned yet', context);
                //           return;
                //         }
                //         Navigator.pushReplacement(
                //           context,
                //           MaterialPageRoute(
                //             builder: (context) => RatingsScreen(
                //                 orderSnap: orderSnap, partnerSnap: partnerSnap, restaurantSnap: restaurantSnap),
                //           ),
                //         );
                //       },
                //       child: Container(
                //         width: MediaQuery.of(context).size.width * 0.96,
                //         height: 50,
                //         alignment: Alignment.center,
                //         decoration: BoxDecoration(
                //           borderRadius: BorderRadius.circular(8),
                //           color: Colors.blue[200],
                //         ),
                //         child: _buttonLoading
                //             ? const Center(
                //                 child: CircularProgressIndicator(),
                //               )
                //             : const Text(
                //                 'Go to Ratings',
                //                 style: TextStyle(
                //                   fontWeight: FontWeight.w600,
                //                   fontSize: 16.5,
                //                   color: Colors.black,
                //                 ),
                //               ),
                //       ),
                //     ),
                //   ),
                // ],
                // persistentFooterButtons: [
                //   Center(
                //     child: InkWell(
                //       onTap: () {
                //         showAlertDialog('Delivery Completed');
                //       },
                //       child: Container(
                //         width: MediaQuery.of(context).size.width * 0.96,
                //         height: 50,
                //         alignment: Alignment.center,
                //         decoration: BoxDecoration(
                //           borderRadius: BorderRadius.circular(8),
                //           color: Colors.blue[200],
                //         ),
                //         child: _buttonLoading
                //             ? const Center(
                //                 child: CircularProgressIndicator(),
                //               )
                //             : const Text(
                //                 'I got the Delivery!',
                //                 style: TextStyle(
                //                   fontWeight: FontWeight.w600,
                //                   fontSize: 16.5,
                //                   color: Colors.black,
                //                 ),
                //               ),
                //       ),
                //     ),
                //   ),
                // ],
              );
  }
}
