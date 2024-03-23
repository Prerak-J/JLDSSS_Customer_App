import 'package:customer_app/pages/order_page.dart';
import 'package:customer_app/resources/search_methods.dart';
import 'package:customer_app/utils/colors.dart';
import 'package:customer_app/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class FoodSearchScreen extends StatefulWidget {
  final Map<String, dynamic> snap;
  const FoodSearchScreen({super.key, required this.snap});

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> with SingleTickerProviderStateMixin {
  List<int> counter = [];
  int sum = 0;
  List<Map<String, dynamic>> foodList = [{}];
  bool _isLoading = false;
  List<int> filteredIndices = [];
  late AnimationController popUpAnimationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );

  @override
  void initState() {
    super.initState();
    counter = List.filled(widget.snap['foodlist'].length, 0);
    sum = 0;
    popUpAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    fetch();
  }

  void fetch() async {
    setState(() {
      _isLoading = true;
    });
    foodList = await SearchMethods().getFoodItems(widget.snap['resUid']);
    print('filtered foodlist ${widget.snap['resUid']}');
    setState(() {
      _isLoading = false;
    });
  }

  void filterSearchResults(String query) {
    // filteredRestaurants.clear();
    filteredIndices.clear();
    if (query.isNotEmpty) {
      // for (var restaurant in restaurants) {
      //   if (restaurant.toLowerCase().contains(query.toLowerCase())) {
      //     filteredRestaurants.add(restaurant);
      //   }
      // }
      for (int i = 0; i < foodList.length; i++) {
        if (foodList[i]['NAME'].toLowerCase().contains(query.toLowerCase())) {
          filteredIndices.add(i);
        }
      }
      print('filteredIndices: $filteredIndices ${foodList.length}');
    }
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    popUpAnimationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menuWidth = MediaQuery.of(context).size.width * 0.955;
    return _isLoading
        ? const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          )
        : Scaffold(
            resizeToAvoidBottomInset: true,
            body: Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      leadingWidth: 26,
                      elevation: 2,
                      shadowColor: lightGrey,
                      floating: true,
                      title: TextField(
                        onChanged: (value) {
                          filterSearchResults(value);
                        },
                        decoration: InputDecoration(
                          hintText: 'Search food in ${widget.snap['name']}...',
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 20),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
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
                                color: widget.snap['foodlist'][filteredIndices[index]]['AVAILABLE']
                                    ? Colors.white
                                    : Colors.grey[400],
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
                                          index: filteredIndices[index],
                                          menuwidth: menuWidth,
                                        ),
                                      ).then((value) {
                                        if (value > 0) {
                                          setState(() {
                                            counter[filteredIndices[index]] = value;
                                            sum = counter.sum;
                                            popUpAnimationController.forward();
                                          });
                                        }
                                      }),
                                      child: Container(
                                        padding:
                                            const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                        alignment: Alignment.topLeft,
                                        // color: lightGreen,
                                        width: menuWidth * 0.63,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Align(
                                              alignment: const Alignment(-1.02, -1),
                                              child: widget.snap['foodlist'][filteredIndices[index]]
                                                          ['type'] ==
                                                      'veg'
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
                                              widget.snap['foodlist'][filteredIndices[index]]
                                                  ['NAME'],
                                              style: const TextStyle(
                                                  fontSize: 16, fontWeight: FontWeight.w500),
                                            ),
                                            Text(
                                              '₹${widget.snap['foodlist'][filteredIndices[index]]['PRICE'].toString()}',
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color: parrotGreen,
                                              ),
                                            ),
                                            Text(
                                              widget.snap['foodlist'][filteredIndices[index]]
                                                  ['DESCRIPTION'],
                                              style: const TextStyle(
                                                  fontSize: 12, fontWeight: FontWeight.w400),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding:
                                          const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                                              borderRadius: BorderRadius.circular(18),
                                              child: Image.network(
                                                'https://images.unsplash.com/photo-1586190848861-99aa4a171e90?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8YnVyZ2VyfGVufDB8fDB8fHww',
                                                height: 120,
                                                color: widget.snap['foodlist']
                                                        [filteredIndices[index]]['AVAILABLE']
                                                    ? null
                                                    : Colors.grey,
                                                colorBlendMode: BlendMode.hue,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 6,
                                          ),
                                          counter[filteredIndices[index]] > 0
                                              ? Container(
                                                  constraints: BoxConstraints(
                                                    maxWidth: menuWidth * 0.28,
                                                  ),
                                                  padding: const EdgeInsets.all(2),
                                                  // width: menuWidth * 0.16,
                                                  decoration: BoxDecoration(
                                                    border:
                                                        Border.all(color: secondaryGreen, width: 2),
                                                    borderRadius: BorderRadius.circular(10),
                                                    color: Theme.of(context).primaryColor,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      InkWell(
                                                        onTap: () =>
                                                            counter[filteredIndices[index]] > 0
                                                                ? setState(() {
                                                                    counter[
                                                                        filteredIndices[index]]--;
                                                                    sum = counter.sum;
                                                                    if (sum == 0) {
                                                                      popUpAnimationController
                                                                          .reverse();
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
                                                        margin: const EdgeInsets.symmetric(
                                                            horizontal: 3),
                                                        padding: const EdgeInsets.symmetric(
                                                            horizontal: 3, vertical: 2),
                                                        decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(3),
                                                            color: Theme.of(context).primaryColor),
                                                        child: Text(
                                                          counter[filteredIndices[index]] == 0
                                                              ? 'ADD'
                                                              : '${counter[filteredIndices[index]]}',
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
                                                            counter[filteredIndices[index]]++;
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
                                                    border:
                                                        Border.all(color: secondaryGreen, width: 2),
                                                    borderRadius: BorderRadius.circular(10),
                                                    color: widget.snap['foodlist']
                                                                    [filteredIndices[index]]
                                                                ['AVAILABLE'] &&
                                                            (widget.snap['open'])
                                                        ? lightGreen
                                                        : Colors.grey,
                                                  ),
                                                  child: InkWell(
                                                    onTap: () {
                                                      if (widget.snap['foodlist']
                                                                  [filteredIndices[index]]
                                                              ['AVAILABLE'] &&
                                                          (widget.snap['open'])) {
                                                        setState(() {
                                                          counter[filteredIndices[index]]++;
                                                          sum = counter.sum;
                                                          popUpAnimationController.forward();
                                                        });
                                                      } else if (!(widget.snap['open'])) {
                                                        showSnackBar(
                                                            'Restaurant is closed!', context);
                                                      } else {
                                                        showSnackBar('Item unavailable!', context);
                                                      }
                                                    },
                                                    child: Center(
                                                      child: Container(
                                                        margin: const EdgeInsets.symmetric(
                                                            horizontal: 3),
                                                        padding: const EdgeInsets.symmetric(
                                                            horizontal: 3, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(3),
                                                          color: widget.snap['foodlist']
                                                                          [filteredIndices[index]]
                                                                      ['AVAILABLE'] &&
                                                                  (widget.snap['open'])
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
                        childCount: filteredIndices.length,
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
                    position: Tween<Offset>(begin: const Offset(0, 1.5), end: Offset.zero)
                        .animate(popUpAnimationController),
                    child: InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderScreen(
                            snap: widget.snap,
                            counter: counter,
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
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3), color: Colors.white),
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
                  color: widget.snap['foodlist'][widget.index]['AVAILABLE'] && widget.snap['open']
                      ? const Color.fromARGB(255, 6, 79, 53)
                      : Colors.grey,
                ),
                child: InkWell(
                  onTap: () {
                    if (widget.snap['foodlist'][widget.index]['AVAILABLE'] && widget.snap['open']) {
                      Navigator.pop(context, counter);
                    } else if (!(widget.snap['open'])) {
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
