import 'package:customer_app/resources/auth_methods.dart';
import 'package:customer_app/utils/colors.dart';
import 'package:customer_app/utils/utils.dart';
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
  double sum = 0;
  var _userData = {};
  String name = '';
  String email = '';
  String phone = '';
  String address = '';
  bool _isLoading = false;

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
    ))!;
    setState(() {
      _isLoading = false;
      name = _userData['name'];
      email = _userData['email'];
      phone = _userData['phone'];
      address = _userData['address'];
    });
  }

  void placeOrder() async {
    setState(() {
      _isLoading = true;
    });
    for (int i = 0; i < values.length; i++) {
      orders.add('${widget.snap['foodlist'][indice[i]]['NAME']} x ${values[i].toString()}');
      prices.add('₹${(widget.snap['foodlist'][indice[i]]['PRICE'] * values[i]).toString()}');
    }

    String res = await AuthMethods().addActiveOrder(
      resName: widget.snap['name'],
      orders: orders,
      prices: prices,
      total: sum,
    );

    if (context.mounted) {
      if (res == 'success') {
        Navigator.pop(context);
        Navigator.pop(context);
        showSnackBar('Order Placed !', context);
      } else {
        showSnackBar(res, context);
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final menuWidth = MediaQuery.of(context).size.width * 0.955;
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
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
                                      style: const TextStyle(
                                          fontSize: 16, fontWeight: FontWeight.w500),
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
                                                  onTap: () => values[index] > 0
                                                      ? setState(() {
                                                          values[index]--;
                                                          sum = 0;
                                                          for (int i = 0; i < values.length; i++) {
                                                            sum += values[i] *
                                                                (widget.snap['foodlist'][indice[i]]
                                                                    ['PRICE']);
                                                          }
                                                        })
                                                      : {},
                                                  child: const Icon(
                                                    Icons.remove,
                                                    color: secondaryGreen,
                                                    size: 12,
                                                  ),
                                                ),
                                                Flexible(child: Container()),
                                                Container(
                                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 3, vertical: 2),
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(3),
                                                      color: Colors.white),
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
                                                      sum = 0;
                                                      for (int i = 0; i < values.length; i++) {
                                                        sum += values[i] *
                                                            (widget.snap['foodlist'][indice[i]]
                                                                ['PRICE']);
                                                      }
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
                                                  sum = 0;
                                                  for (int i = 0; i < values.length; i++) {
                                                    sum += values[i] *
                                                        (widget.snap['foodlist'][indice[i]]
                                                            ['PRICE']);
                                                  }
                                                });
                                              },
                                              child: Center(
                                                child: Container(
                                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 3, vertical: 2),
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(3),
                                                      color: lightGreen),
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
                      padding: EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 8,
                      ),
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
                  onTap: placeOrder, //PLACING ORDER
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '₹${sum.toString()}',
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
                              style: TextStyle(
                                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
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
