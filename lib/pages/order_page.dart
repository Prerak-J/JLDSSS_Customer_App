import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:customer_app/pages/address_page.dart';
import 'package:customer_app/resources/auth_methods.dart';
import 'package:customer_app/screens/map_screen.dart';
import 'package:customer_app/utils/colors.dart';
import 'package:customer_app/utils/utils.dart';
import 'package:customer_app/widgets/discount_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OrderScreen extends StatefulWidget {
  final Map<String, dynamic> snap;
  final List<int> counter;
  const OrderScreen({
    super.key,
    required this.snap,
    required this.counter,
  });

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  int items = 0;
  List<String> orders = [];
  List<String> prices = [];
  List<int> values = [];
  List<int> indice = [];
  double sum = 0.00;
  double grdTotal = 0.00;
  double toPay = 0.00;
  double gst = 0.00;
  double deliveryFee = 0.00;
  double platformFee = 0.00;
  var _userData = {};
  String name = '';
  String email = '';
  String phone = '';
  String address = '';
  double latitude = 0.0;
  double longitude = 0.0;
  bool _isLoading = false;
  Map<String, dynamic> couponApplied = {};
  double couponDiscount = 0.0;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    for (int i = 0; i < widget.counter.length; i++) {
      if (widget.counter[i] != 0) {
        values.add(widget.counter[i]);
        indice.add(i);
      }
    }
    items = indice.length;
    for (int i = 0; i < values.length; i++) {
      sum += values[i] * (widget.snap['foodlist'][indice[i]]['PRICE']);
    }
    _isLoading = false;
    fetch();
  }

  void fetch() async {
    setState(() {
      _isLoading = true;
    });
    _userData = (await AuthMethods().getUserData(
          FirebaseAuth.instance.currentUser!.uid,
        )) ??
        {};
    if (_userData.isEmpty && mounted) {
      showSnackBar("Some error occured", context);
      Navigator.pop(context);
    }
    var pricesSnap = await FirebaseFirestore.instance.collection('prices').doc('prices@admin').get();
    setState(() {
      _isLoading = false;
      name = _userData['name'];
      email = _userData['email'];
      phone = _userData['phone'];
      address = _userData['address'] ?? 'Add Address';

      if (_userData['addressList'] != null && _userData['addressList'].length > 0) {
        latitude = _userData['addressList'][_userData['defaultAddress']]['latitude'] ?? 0.0;
        longitude = _userData['addressList'][_userData['defaultAddress']]['longitude'] ?? 0.0;
        // print("CHECK ME: $latitude");
        // print("CHECK ME: $longitude");
      }
      gst = pricesSnap.data()!['gst'].toDouble();
      deliveryFee = pricesSnap.data()!['partnerFee'].toDouble();
      platformFee = pricesSnap.data()!['platformFee'].toDouble();
      grdTotal = sum + ((gst * sum) / 100) + deliveryFee + platformFee;
      toPay = grdTotal;
    });
  }

  void placeOrder() async {
    if (_userData['address'] == "Add Address" || _userData['address'] == null) {
      showSnackBar('Please add an address', context);
      return;
    }
    if (values.sum > 0) {
      setState(() {
        _isLoading = true;
      });
      for (int i = 0; i < values.length; i++) {
        if (values[i] > 0) {
          orders.add('${widget.snap['foodlist'][indice[i]]['NAME']} x ${values[i].toString()}');
          prices.add('₹${(widget.snap['foodlist'][indice[i]]['PRICE'] * values[i]).toString()}');
        }
      }

      String res = await AuthMethods().addActiveOrder(
        resName: widget.snap['name'],
        resUid: widget.snap['resUid'],
        orders: orders,
        prices: prices,
        total: sum,
        grdTotal: double.parse(grdTotal.toStringAsFixed(2)),
        toPay: double.parse(toPay.toStringAsFixed(2)),
        name: name,
        email: email,
        phone: phone,
        address: address,
        resAddress: widget.snap['address'],
        gst: gst,
        deliveryFee: deliveryFee,
        platformFee: platformFee,
        latitude: latitude,
        longitude: longitude,
        couponApplied: couponApplied,
      );

      if (mounted) {
        if (res == 'success') {
          // showSnackBar('Order Placed but Working on Map !', context);
          showSnackBar('Order Placed !', context);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const MapScreen(),
            ),
            ((route) => route.isFirst),
          );
        } else {
          showSnackBar(res, context);
        }
      }

      setState(() {
        _isLoading = false;
      });
    } else {
      showSnackBar('Please add a food item', context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuWidth = MediaQuery.of(context).size.width * 0.955;
    return _isLoading
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            backgroundColor: Colors.grey[350],
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.grey[350],
                  floating: true,
                  leadingWidth: 35,
                  title: Text(
                    widget.snap['name'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 8,
                      ),
                      child: Text(
                        'Order Summary :',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 16,
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
                        child: ListView.builder(
                          padding: const EdgeInsets.all(0),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: items,
                          itemBuilder: (context, index) => Column(
                            children: [
                              ListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                dense: true,
                                visualDensity: const VisualDensity(vertical: 4),
                                tileColor: lightGrey,
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Align(
                                      alignment: const Alignment(-1.02, -1),
                                      child: widget.snap['foodlist'][indice[index]]['type'] == 'veg'
                                          ? const Icon(
                                              CupertinoIcons.dot_square,
                                              color: Color(0xff14801b),
                                              size: 18,
                                            )
                                          : const Icon(
                                              CupertinoIcons.arrowtriangle_up_square,
                                              color: Color(0xff8a4528),
                                              size: 18,
                                            ),
                                    ),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    Text(
                                      widget.snap['foodlist'][indice[index]]['NAME'],
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(
                                      height: 40,
                                    ),
                                  ],
                                ),
                                trailing: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const SizedBox(
                                      height: 7,
                                    ),
                                    values[index] > 0
                                        ? Container(
                                            constraints: BoxConstraints(
                                              maxWidth: menuWidth * 0.17,
                                            ),
                                            padding: const EdgeInsets.all(2),
                                            // width: menuWidth * 0.16,
                                            decoration: BoxDecoration(
                                              border: Border.all(color: secondaryGreen, width: 2),
                                              borderRadius: BorderRadius.circular(10),
                                              color: Colors.white,
                                            ),
                                            child: Row(
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    if (values[index] > 0 && values.sum > 1) {
                                                      setState(() {
                                                        values[index]--;
                                                        sum = 0.00;
                                                        for (int i = 0; i < values.length; i++) {
                                                          sum +=
                                                              values[i] * (widget.snap['foodlist'][indice[i]]['PRICE']);
                                                        }
                                                        grdTotal =
                                                            sum + ((gst * sum) / 100) + deliveryFee + platformFee;
                                                        toPay = grdTotal - 60.00;
                                                      });
                                                    } else if (values.sum <= 1) {
                                                      Navigator.pop(context);
                                                    }
                                                  },
                                                  child: const Icon(
                                                    Icons.remove,
                                                    color: secondaryGreen,
                                                    size: 12,
                                                  ),
                                                ),
                                                Flexible(child: Container()),
                                                Container(
                                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(3), color: Colors.white),
                                                  child: Text(
                                                    '${values[index]}',
                                                    style: const TextStyle(
                                                      color: secondaryGreen,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                                Flexible(child: Container()),
                                                InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      values[index]++;
                                                      sum = 0.00;
                                                      for (int i = 0; i < values.length; i++) {
                                                        sum +=
                                                            values[i] * (widget.snap['foodlist'][indice[i]]['PRICE']);
                                                      }
                                                      grdTotal = sum + ((gst * sum) / 100) + deliveryFee + platformFee;
                                                      toPay = grdTotal - 60.00;
                                                    });
                                                  },
                                                  child: const Icon(
                                                    Icons.add,
                                                    color: secondaryGreen,
                                                    size: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : Container(
                                            constraints: BoxConstraints(
                                              maxWidth: menuWidth * 0.17,
                                            ),
                                            padding: const EdgeInsets.all(2),
                                            // width: menuWidth * 0.16,
                                            decoration: BoxDecoration(
                                              border: Border.all(color: secondaryGreen, width: 2),
                                              borderRadius: BorderRadius.circular(10),
                                              color: lightGreen,
                                            ),
                                            child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  values[index]++;
                                                  sum = 0.00;
                                                  for (int i = 0; i < values.length; i++) {
                                                    sum += values[i] * (widget.snap['foodlist'][indice[i]]['PRICE']);
                                                  }
                                                  grdTotal = sum + ((gst * sum) / 100) + deliveryFee + platformFee;
                                                  toPay = grdTotal - 60.00;
                                                });
                                              },
                                              child: Center(
                                                child: Container(
                                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(3), color: lightGreen),
                                                  child: const Text(
                                                    'ADD +',
                                                    style: TextStyle(
                                                        color: secondaryGreen,
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w600),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                    const SizedBox(
                                      height: 7,
                                    ),
                                    Text(
                                      '₹${(widget.snap['foodlist'][indice[index]]['PRICE'] * values[index]).toString()}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: parrotGreen,
                                      ),
                                    ),
                                  ],
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
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(15, 12, 15, 0),
                      child: Text(
                        'Delivering to :',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddressScreen(),
                          ),
                        ).then((value) {
                          fetch();
                        }),
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
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        email,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Color.fromARGB(255, 31, 129, 34),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                        phone,
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      Text(
                                        address,
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          color: address == 'Add Address' ? Colors.teal : Colors.black54,
                                          fontWeight: address == 'Add Address' ? FontWeight.bold : FontWeight.normal,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.keyboard_arrow_right_rounded,
                                  size: 22,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(15, 12, 15, 2),
                      child: Text(
                        'Available discount coupons :',
                        style: TextStyle(fontStyle: FontStyle.italic, fontSize: 16, color: appBarGreen),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 2, 12, 12),
                      child: Material(
                        borderRadius: BorderRadius.circular(8),
                        elevation: 5,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 0,
                          ),
                          onTap: () => showModalBottomSheet(
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                            ),
                            isScrollControlled: true,
                            context: context,
                            builder: (context) => DiscountSheet(
                              snap: widget.snap,
                              menuwidth: menuWidth,
                              grdTotal: grdTotal,
                            ),
                          ).then(
                            (value) {
                              setState(() {
                                couponApplied = Map<String, dynamic>.from(value as Map<String, dynamic>);
                                couponDiscount = ((couponApplied['discount'] * grdTotal) / 100) > couponApplied['limit']
                                    ? couponApplied['limit']
                                    : (couponApplied['discount'] * grdTotal) / 100;

                                toPay = grdTotal - couponDiscount;
                              });
                              // print(couponApplied);
                            },
                          ),
                          dense: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          tileColor: lightGrey,
                          title: Row(
                            children: couponApplied.isEmpty
                                ? [
                                    const Text(
                                      "  Select a coupon",
                                      style: TextStyle(fontSize: 13.5),
                                    ),
                                  ]
                                : [
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      color: parrotGreen,
                                    ),
                                    Text(
                                      " You saved ${couponDiscount.toStringAsFixed(0)} with '${couponApplied['name']}'",
                                      style: const TextStyle(fontSize: 13.5),
                                    ),
                                  ],
                          ),
                          trailing: const Icon(
                            Icons.keyboard_arrow_right,
                            size: 22,
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
                                    '₹${sum.toString()}',
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
                                    '₹${((gst * sum) / 100).toStringAsFixed(2)}',
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
                                    '₹ $deliveryFee',
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
                                    '₹ $platformFee',
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
                                    '₹${grdTotal.toStringAsFixed(2)}',
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
                                    couponApplied.isEmpty
                                        ? 'No Coupon Applied'
                                        : 'Restaurant coupon - (${couponApplied['name']})',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      // fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '- ₹${couponDiscount.toStringAsFixed(2)}',
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
                                    'To pay',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '₹${toPay.toStringAsFixed(2)}',
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
                      height: 12,
                    ),
                  ]),
                ),
              ],
            ),
            persistentFooterAlignment: AlignmentDirectional.centerEnd,
            persistentFooterButtons: [
              Container(
                width: double.infinity,
                height: 70,
                padding: const EdgeInsets.all(2),
                // width: menuWidth * 0.16,
                decoration: BoxDecoration(
                  border: Border.all(color: secondaryGreen, width: 2),
                  borderRadius: BorderRadius.circular(10),
                  color: const Color.fromARGB(255, 4, 68, 46),
                ),
                child: InkWell(
                  onTap: () {
                    ((_userData['activeOrder'] == null) || !_userData['activeOrder'])
                        ? placeOrder()
                        : showSnackBar("You already have an active order!", context);
                  }, //PLACING ORDER
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '₹${toPay.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            const Text(
                              'TOTAL',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Flexible(child: Container()),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Place Order ',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            Icon(
                              Icons.keyboard_arrow_right_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
  }
}

class DiscountSheet extends StatefulWidget {
  final Map<String, dynamic> snap;
  final double menuwidth;
  final double grdTotal;
  const DiscountSheet({
    super.key,
    required this.snap,
    required this.menuwidth,
    required this.grdTotal,
  });

  @override
  State<DiscountSheet> createState() => _DiscountSheetState();
}

class _DiscountSheetState extends State<DiscountSheet> {
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      maxChildSize: 0.88,
      initialChildSize: 0.7,
      minChildSize: 0.32,
      expand: false,
      builder: (_, scrollController) => Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: AppBar(
              automaticallyImplyLeading: false,
              centerTitle: true,
              title: Container(
                width: widget.menuwidth * 0.2,
                height: 5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey,
                ),
                padding: const EdgeInsets.only(top: 12),
              ),
            ),
          ),
          body: DiscountList(
            discountList: List<Map<String, dynamic>>.from(widget.snap['discountList']),
            grdTotal: widget.grdTotal,
          ),
        ),
      ),
    );
  }
}
