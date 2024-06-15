import 'package:auto_size_text/auto_size_text.dart';
import 'package:customer_app/pages/address_page.dart';
import 'package:customer_app/pages/order_page.dart';
import 'package:customer_app/screens/food_search_screen.dart';
import 'package:customer_app/utils/colors.dart';
import 'package:customer_app/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class MenuScreen extends StatefulWidget {
  final Map<String, dynamic> snap;
  const MenuScreen({super.key, required this.snap});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with SingleTickerProviderStateMixin {
  String selectedCategory = "All items";
  String selectedType = "All types";
  Color? selectedColor = Colors.blue[900];
  List<int> counter = [];
  int sum = 0;
  int noOfItems = 0;
  late AnimationController popUpAnimationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );

  @override
  void initState() {
    super.initState();
    counter = List.filled(widget.snap['foodlist'] != null ? widget.snap['foodlist'].length : 0, 0);
    sum = 0;
    popUpAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    super.dispose();
    popUpAnimationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menuWidth = MediaQuery.of(context).size.width * 0.955;
    String symbol = widget.snap['type'].contains('Veg/Non-Veg') ? '🥬🍖' : '🥬';
    return Scaffold(
      backgroundColor: lightGrey,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                elevation: 2,
                shadowColor: lightGrey,
                backgroundColor: lightGrey,
                floating: true,
                actions: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: IconButton(
                      icon: const Icon(
                        Icons.search,
                        size: 26,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FoodSearchScreen(snap: widget.snap),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  Container(
                    height: 130,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      alignment: Alignment.topCenter,
                      child: Column(
                        children: [
                          Container(
                            constraints: const BoxConstraints(maxHeight: 55),
                            child: AutoSizeText(
                              widget.snap['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                              ),
                              minFontSize: 22,
                              // maxFontSize: 20,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '  ${widget.snap['type']} $symbol   ',
                                style: const TextStyle(fontSize: 14),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: !(widget.snap.containsKey('rating'))
                                      ? Colors.grey[350]
                                      : widget.snap['rating'] >= 4.0
                                          ? Colors.green[900]
                                          : widget.snap['rating'] >= 3.0
                                              ? Colors.green[700]
                                              : widget.snap['rating'] >= 2.0
                                                  ? Colors.brown
                                                  : widget.snap['rating'] >= 1.0
                                                      ? Colors.red[400]
                                                      : Colors.red[800],
                                ),
                                child: !(widget.snap.containsKey('rating'))
                                    ? const Text(
                                        'No Ratings yet',
                                        style: TextStyle(color: Colors.black, fontSize: 11),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            widget.snap['rating'].toStringAsFixed(1),
                                            style: const TextStyle(color: Colors.white, fontSize: 11),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.only(bottom: 2),
                                            child: Icon(
                                              Icons.star_rate_rounded,
                                              color: Colors.amber,
                                              size: 16,
                                            ),
                                          )
                                        ],
                                      ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                ]),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      typeName('All types'),
                      typeName('Veg'),
                      typeName('Non-Veg'),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        categoryName('All items'),
                        categoryName('Starters'),
                        categoryName('Combos'),
                        categoryName('Main Course'),
                        categoryName('Desserts'),
                      ],
                    ),
                  ),
                ),
              ),
              counter.isEmpty
                  ? const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(top: 100),
                        child: Column(
                          children: [
                            Icon(
                              Icons.no_food_rounded,
                              size: 40,
                            ),
                            Text('No items currently')
                          ],
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (selectedCategory != 'All items' || selectedType != 'All types') {
                            if (selectedType == 'All types') {
                              if (widget.snap['foodlist'][index]['category'] != selectedCategory) {
                                noOfItems++;
                                if (index == counter.length - 1 && noOfItems == counter.length) {
                                  return const Padding(
                                    padding: EdgeInsets.only(top: 100),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.no_food_rounded,
                                          size: 40,
                                        ),
                                        Text('No such items currently')
                                      ],
                                    ),
                                  );
                                } else {
                                  return Container();
                                }
                              }
                            }
                            if (selectedType == 'Veg') {
                              if (selectedCategory != 'All items') {
                                if (widget.snap['foodlist'][index]['category'] != selectedCategory ||
                                    widget.snap['foodlist'][index]['type'] != 'veg') {
                                  noOfItems++;
                                  if (index == counter.length - 1 && noOfItems == counter.length) {
                                    return const Padding(
                                      padding: EdgeInsets.only(top: 100),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.no_food_rounded,
                                            size: 40,
                                          ),
                                          Text('No such items currently')
                                        ],
                                      ),
                                    );
                                  } else {
                                    return Container();
                                  }
                                }
                              } else {
                                if (widget.snap['foodlist'][index]['type'] != 'veg') {
                                  noOfItems++;
                                  if (index == counter.length - 1 && noOfItems == counter.length) {
                                    return const Padding(
                                      padding: EdgeInsets.only(top: 100),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.no_food_rounded,
                                            size: 40,
                                          ),
                                          Text('No such items currently')
                                        ],
                                      ),
                                    );
                                  } else {
                                    return Container();
                                  }
                                }
                              }
                            }
                            if (selectedType == 'Non-Veg') {
                              if (selectedCategory != 'All items') {
                                if (widget.snap['foodlist'][index]['category'] != selectedCategory ||
                                    widget.snap['foodlist'][index]['type'] != 'non_veg') {
                                  noOfItems++;
                                  if (index == counter.length - 1 && noOfItems == counter.length) {
                                    return const Padding(
                                      padding: EdgeInsets.only(top: 100),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.no_food_rounded,
                                            size: 40,
                                          ),
                                          Text('No such items currently')
                                        ],
                                      ),
                                    );
                                  } else {
                                    return Container();
                                  }
                                }
                              } else {
                                if (widget.snap['foodlist'][index]['type'] != 'non_veg') {
                                  noOfItems++;
                                  if (index == counter.length - 1 && noOfItems == counter.length) {
                                    return const Padding(
                                      padding: EdgeInsets.only(top: 100),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.no_food_rounded,
                                            size: 40,
                                          ),
                                          Text('No such items currently')
                                        ],
                                      ),
                                    );
                                  } else {
                                    return Container();
                                  }
                                }
                              }
                            }
                          }
                          return Column(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.95,
                                height: 0.5,
                                decoration: const BoxDecoration(
                                  color: Colors.grey,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey,
                                      blurRadius: 1,
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                color: widget.snap['foodlist'][index]['AVAILABLE'] ? Colors.white : Colors.grey[350],
                                height: 190,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 8,
                                ),
                                child: Row(
                                  children: [
                                    InkWell(
                                      onTap: () => showModalBottomSheet(
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(30),
                                          ),
                                        ),
                                        isScrollControlled: true,
                                        context: context,
                                        builder: (context) => BuildSheet(
                                          snap: widget.snap,
                                          index: index,
                                          menuwidth: menuWidth,
                                        ),
                                      ).then((value) {
                                        if (value > 0) {
                                          setState(() {
                                            counter[index] = value;
                                            sum = counter.sum;
                                            popUpAnimationController.forward();
                                          });
                                        }
                                      }),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                        alignment: Alignment.topLeft,
                                        // color: lightGreen,
                                        width: menuWidth * 0.63,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Align(
                                              alignment: const Alignment(-1.02, -1),
                                              child: widget.snap['foodlist'][index]['type'] == 'veg'
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
                                              widget.snap['foodlist'][index]['NAME'],
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                            ),
                                            Text(
                                              '₹${widget.snap['foodlist'][index]['PRICE'].toString()}',
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color: parrotGreen,
                                              ),
                                            ),
                                            Text(
                                              widget.snap['foodlist'][index]['DESCRIPTION'],
                                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      // color: Colors.green,
                                      width: menuWidth * 0.37,
                                      alignment: Alignment.topCenter,
                                      child: Column(
                                        // alignment: const Alignment(0, 1.5),
                                        children: [
                                          SizedBox(
                                            height: 110,
                                            width: 110,
                                            child: ClipRRect(
                                              clipBehavior: Clip.hardEdge,
                                              borderRadius: BorderRadius.circular(18),
                                              child: (widget.snap['foodlist'][index]['photoURL'] != null &&
                                                      widget.snap['foodlist'][index]['photoURL'] != '')
                                                  ? Image.network(
                                                      widget.snap['foodlist'][index]['photoURL'],
                                                      height: 120,
                                                      fit: BoxFit.cover,
                                                      cacheWidth: (MediaQuery.of(context).size.width *
                                                              MediaQuery.of(context).devicePixelRatio)
                                                          .round(),
                                                      color: widget.snap['foodlist'][index]['AVAILABLE']
                                                          ? null
                                                          : Colors.grey,
                                                      colorBlendMode: BlendMode.hue,
                                                    )
                                                  : Image.network(
                                                      'https://images.unsplash.com/photo-1586190848861-99aa4a171e90?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8YnVyZ2VyfGVufDB8fDB8fHww',
                                                      height: 120,
                                                      fit: BoxFit.cover,
                                                      cacheWidth: (MediaQuery.of(context).size.width *
                                                              MediaQuery.of(context).devicePixelRatio)
                                                          .round(),
                                                      color: widget.snap['foodlist'][index]['AVAILABLE']
                                                          ? null
                                                          : Colors.grey,
                                                      colorBlendMode: BlendMode.hue,
                                                    ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 6,
                                          ),
                                          counter[index] > 0
                                              ? Container(
                                                  constraints: BoxConstraints(
                                                    maxWidth: menuWidth * 0.28,
                                                  ),
                                                  padding: const EdgeInsets.all(2),
                                                  // width: menuWidth * 0.16,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(color: secondaryGreen, width: 2),
                                                    borderRadius: BorderRadius.circular(10),
                                                    color: Theme.of(context).primaryColor,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      InkWell(
                                                        onTap: () => counter[index] > 0
                                                            ? setState(() {
                                                                counter[index]--;
                                                                sum = counter.sum;
                                                                if (sum == 0) {
                                                                  popUpAnimationController.reverse();
                                                                }
                                                              })
                                                            : {},
                                                        child: const Icon(
                                                          Icons.remove,
                                                          color: Colors.white,
                                                          size: 16,
                                                        ),
                                                      ),
                                                      Flexible(child: Container()),
                                                      Container(
                                                        margin: const EdgeInsets.symmetric(horizontal: 3),
                                                        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                                                        decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(3),
                                                            color: Theme.of(context).primaryColor),
                                                        child: Text(
                                                          counter[index] == 0 ? 'ADD' : '${counter[index]}',
                                                          style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                      ),
                                                      Flexible(child: Container()),
                                                      InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            counter[index]++;
                                                            sum = counter.sum;
                                                            popUpAnimationController.forward();
                                                          });
                                                        },
                                                        child: const Icon(
                                                          Icons.add,
                                                          color: Colors.white,
                                                          size: 16,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : Container(
                                                  constraints: BoxConstraints(
                                                    maxWidth: menuWidth * 0.28,
                                                  ),
                                                  padding: const EdgeInsets.all(2),
                                                  // width: menuWidth * 0.16,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(color: secondaryGreen, width: 2),
                                                    borderRadius: BorderRadius.circular(10),
                                                    color: widget.snap['foodlist'][index]['AVAILABLE'] &&
                                                            (widget.snap['open'] && widget.snap['openAdmin'])
                                                        ? lightGreen
                                                        : Colors.grey,
                                                  ),
                                                  child: InkWell(
                                                    onTap: () {
                                                      if (widget.snap['foodlist'][index]['AVAILABLE'] &&
                                                          (widget.snap['open'] && widget.snap['openAdmin'])) {
                                                        setState(() {
                                                          counter[index]++;
                                                          sum = counter.sum;
                                                          popUpAnimationController.forward();
                                                        });
                                                      } else if (!(widget.snap['open'] && widget.snap['openAdmin'])) {
                                                        showSnackBar('Restaurant is closed!', context);
                                                      } else {
                                                        showSnackBar('Item unavailable!', context);
                                                      }
                                                    },
                                                    child: Center(
                                                      child: Container(
                                                        margin: const EdgeInsets.symmetric(horizontal: 3),
                                                        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(3),
                                                          color: (widget.snap['foodlist'][index]['AVAILABLE'] &&
                                                                  (widget.snap['open'] && widget.snap['openAdmin']))
                                                              ? lightGreen
                                                              : Colors.grey,
                                                        ),
                                                        child: const Text(
                                                          'ADD +',
                                                          style: TextStyle(
                                                              color: secondaryGreen,
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.w600),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                        childCount: widget.snap['foodlist'] != null ? widget.snap['foodlist'].length : 0,
                      ),
                    ),
              SliverToBoxAdapter(
                child: Container(
                  height: 80,
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(popUpAnimationController),
              child: InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddressScreen(),
                  ),
                ).then(
                  (value) => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderScreen(
                        snap: widget.snap,
                        counter: counter,
                      ),
                    ),
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: tealColor.withGreen(45),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(15),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  width: double.infinity,
                  height: 80,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$sum item(s) added to cart ',
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        const Icon(
                          Icons.arrow_circle_right_rounded,
                          color: Colors.greenAccent,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget categoryName(String category) {
    bool isSelected = category == selectedCategory;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = category;
          noOfItems = 0;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: isSelected ? parrotGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: parrotGreen,
            width: 1,
          ),
        ),
        child: Text(
          category,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget typeName(String type) {
    bool isSelected = type == selectedType;
    Color? borderColor = Colors.black;
    switch (type) {
      case 'Veg':
        borderColor = Colors.green[900];
        break;
      case 'Non-Veg':
        borderColor = darkRed;
        break;
      default:
        borderColor = Colors.blue[900];
        break;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          noOfItems = 0;
          selectedType = type;
          switch (selectedType) {
            case 'Veg':
              selectedColor = Colors.green[900];
              break;
            case 'Non-Veg':
              selectedColor = darkRed;
              break;
            default:
              selectedColor = Colors.blue[900];
              break;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: borderColor ?? Colors.black,
            width: 1,
          ),
        ),
        child: Text(
          type,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class BuildSheet extends StatefulWidget {
  final Map<String, dynamic> snap;
  final int index;
  final double menuwidth;
  const BuildSheet({
    super.key,
    required this.snap,
    required this.index,
    required this.menuwidth,
  });

  @override
  State<BuildSheet> createState() => _BuildSheetState();
}

class _BuildSheetState extends State<BuildSheet> {
  int counter = 1;
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      maxChildSize: 0.7,
      initialChildSize: 0.5,
      minChildSize: 0.32,
      expand: false,
      builder: (_, controller) => Scaffold(
        backgroundColor: lightGrey,
        body: Container(
          color: Colors.white,
          width: double.infinity,
          child: Column(
            children: [
              Container(
                color: lightGreen,
                height: 150,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      alignment: Alignment.topLeft,
                      // color: lightGreen,
                      width: widget.menuwidth * 0.63,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: const Alignment(-1.02, -1),
                            child: widget.snap['foodlist'][widget.index]['type'] == 'veg'
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
                            widget.snap['foodlist'][widget.index]['NAME'],
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '₹${widget.snap['foodlist'][widget.index]['PRICE'].toString()}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: parrotGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      // color: Colors.green,
                      width: widget.menuwidth * 0.37,
                      alignment: Alignment.topCenter,
                      child: Column(
                        // alignment: const Alignment(0, 1.5),
                        children: [
                          SizedBox(
                            height: 110,
                            width: 110,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image.network(
                                'https://images.unsplash.com/photo-1586190848861-99aa4a171e90?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8YnVyZ2VyfGVufDB8fDB8fHww',
                                height: 120,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                alignment: AlignmentDirectional.topStart,
                color: Colors.white,
                child: Text(
                  widget.snap['foodlist'][widget.index]['DESCRIPTION'],
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                ),
              ),
            ],
          ),
        ),
        persistentFooterButtons: [
          Row(
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: widget.menuwidth * 0.25,
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
                      onTap: () => counter > 1
                          ? setState(() {
                              counter--;
                            })
                          : {Navigator.pop(context)},
                      child: const Icon(
                        Icons.remove,
                        color: secondaryGreen,
                        size: 16,
                      ),
                    ),
                    Flexible(child: Container()),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), color: Colors.white),
                      child: Text(
                        counter == 0 ? 'ADD' : '$counter',
                        style: const TextStyle(
                          color: secondaryGreen,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Flexible(child: Container()),
                    InkWell(
                      onTap: () {
                        setState(() {
                          counter++;
                        });
                      },
                      child: const Icon(
                        Icons.add,
                        color: secondaryGreen,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(child: Container()),
              Container(
                width: widget.menuwidth * 0.7,
                height: 40,
                padding: const EdgeInsets.all(2),
                // width: menuWidth * 0.16,
                decoration: BoxDecoration(
                  border: Border.all(color: secondaryGreen, width: 2),
                  borderRadius: BorderRadius.circular(10),
                  color: widget.snap['foodlist'][widget.index]['AVAILABLE'] &&
                          widget.snap['open'] &&
                          widget.snap['openAdmin']
                      ? const Color.fromARGB(255, 6, 79, 53)
                      : Colors.grey,
                ),
                child: InkWell(
                  onTap: () {
                    if (widget.snap['foodlist'][widget.index]['AVAILABLE'] &&
                        widget.snap['open'] &&
                        widget.snap['openAdmin']) {
                      Navigator.pop(context, counter);
                    } else if (!(widget.snap['open'] && widget.snap['openAdmin'])) {
                      showSnackBar('Restaurant is closed!', context);
                    } else {
                      showSnackBar('Item unavailable', context);
                    }
                  },
                  child: Center(
                    child: Text(
                      'Add item  ₹${(widget.snap['foodlist'][widget.index]['PRICE'] * counter).toString()}',
                      style: const TextStyle(color: Colors.white, fontSize: 19),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
        persistentFooterAlignment: AlignmentDirectional.centerEnd,
      ),
    );
  }
}
